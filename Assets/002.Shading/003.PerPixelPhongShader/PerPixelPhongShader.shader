// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/PerPixelPhongShader"{
	Properties{
		_DiffuseColor("Diffuse Color", COLOR) = (1,1,1,1)
		_SpecularColor("Specular Color", COLOR) = (1,1,1,1)
	}
	SubShader{
		Pass{
			CGPROGRAM
#pragma vertex vert
#pragma fragment frag
			struct app_data {
				float4 vertex:POSITION;
				float3 normal:NORMAL;
			};
			struct v2f {
				float4 vertex:SV_POSITION;
				float4 position:TEXCOORD0;
				float4 normal:TEXCOORD1;
			};

			uniform float4 light_pos;
			uniform float4 camera_pos;
			uniform float k_diffuse;
			uniform float k_ambient;
			uniform float k_specular;
			uniform float shininess;

			float4 _DiffuseColor;
			float4 _SpecularColor;

			v2f vert(app_data i) {
				v2f o;

				o.vertex = UnityObjectToClipPos(i.vertex);
				o.position = i.vertex;

				o.normal = mul(UNITY_MATRIX_IT_MV, float4(i.normal, 1));

				return o;
			}

			float4 frag(v2f i) :SV_TARGET{
				float3 vs_light = mul(UNITY_MATRIX_V, light_pos).xyz;
				float3 vs_pos = mul(UNITY_MATRIX_MV, i.position).xyz;
				float3 vs_camera = mul(UNITY_MATRIX_V, camera_pos).xyz;

				float3 vs_n = normalize(i.normal.xyz);
				float3 vs_l = normalize(vs_light - vs_pos);
				float3 vs_v = normalize(vs_camera - vs_pos);
				float3 vs_h = normalize(vs_l + vs_v);

				float r_diffuse = k_diffuse * max(dot(vs_n, vs_l), 0);

				float r_specular = k_specular * pow(max(dot(vs_n, vs_h), 0),shininess);

				return r_diffuse * _DiffuseColor + r_specular * _SpecularColor + k_ambient;
			}
			ENDCG
		}
	}
}
