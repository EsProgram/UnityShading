Shader "Unlit/Gause"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_ND ("n_diffuse", Float) = 1
		_UD ("u_diffuse", Float) = 1
		_NS ("n_specular", Float) = 1
		_US ("u_specular", Float) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 n : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 n : TEXCOORD1;
				float3 cam_pos_w : POSITION1;
				float3 vert_pos_w : POSITION2;
				float3 light_pos_w : POSITION3;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _ND;
			float _NS;
			float _UD;
			float _US;

			float SphericalGaussian(float3 w, float3 e, float n, float u)
			{
				return u * exp(max(n, 0.001) * (dot(e, w) - 1));
			}

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.n = normalize(UnityObjectToWorldNormal(v.n));
				o.cam_pos_w = _WorldSpaceCameraPos;
				o.vert_pos_w = v.vertex;
				o.light_pos_w = normalize(float3(0, 1, 0));
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float3 l = normalize(i.cam_pos_w - i.vert_pos_w);
				float diffuse = SphericalGaussian(i.n, i.light_pos_w, _ND, _UD);
				float specular = SphericalGaussian(i.n, l, _NS, _US);
				float combine = diffuse + specular;
				//return float4(diffuse, diffuse, diffuse, 1);
				//return float4(specular, specular, specular, 1);
				return float4(combine, combine, combine, 1);
			}
			ENDCG
		}
	}
}
