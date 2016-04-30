Shader "Custom/BumpMapShader"{
	Properties{
		_BumpMap("BumpMap", 2D) = "white" {}
		_DiffuseColor("Diffuse Color", COLOR) = (1,1,1,1)

	}
	SubShader{
		Pass{
			CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
			struct app_data {
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float2 texcoord:TEXCOORD0;
				float4 tangent:TANGENT0;
			};
			struct v2f {
				float4 screen:SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 tangentLightDir : TEXCOORD1;
			};

			sampler2D _BumpMap;
			uniform float4 light_pos;
			uniform float k_diffuse;
			uniform float k_ambient;

			float4 _DiffuseColor;
			float4 _SpecularColor;

			float4x4 InvTangentMatrix(
				float3 t,
				float3 b,
				float3 n)
			{
				float4x4 mat = float4x4(
					float4(t.x, t.y, t.z, 0),
					float4(b.x, b.y, b.z, 0),
					float4(n.x, n.y, n.z, 0),
					float4(0, 0, 0, 1)
					);
				return transpose(mat);
			}

			v2f vert(app_data i) {
				v2f o;
				o.screen = mul(UNITY_MATRIX_MVP, i.vertex);
				o.uv = i.texcoord;

				float4 ms_normal = normalize(mul(i.normal, _World2Object));

				float3 n = normalize(ms_normal);
				float3 t = i.tangent;
				float3 b = cross(n, t);

				o.tangentLightDir = mul(light_pos, InvTangentMatrix(t, b, n));
				return o;
			}

			float4 frag(v2f i) :SV_TARGET{
				//float3 normal = normalize(tex2D(_BumpMap, i.uv).xyz * 2.0 - 1.0);
				float3 normal = float4(UnpackNormal(tex2D(_BumpMap, i.uv)),1);
				float3 light = normalize(i.tangentLightDir.xyz);
				float  diffuse = max(0, dot(normal, light)) * k_diffuse;
				return diffuse * _DiffuseColor + k_ambient;
			}
			ENDCG
		}
	}
}
