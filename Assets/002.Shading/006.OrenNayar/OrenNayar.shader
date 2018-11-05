// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/OrenNayar"{
	Properties{
		_Color("Color", COLOR) = (1,1,1,1)
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
				float4 color:COLOR0;
			};

			uniform float4 light_pos;
			uniform float4 camera_pos;
			uniform float k_diffuse;
			uniform float k_ambient;
			uniform float roughness;

			float4 _Color;

			v2f vert(app_data i) {
				v2f o;
				float3 vs_normal = mul(UNITY_MATRIX_IT_MV, float4(i.normal, 1));
				float3 vs_pos = mul(UNITY_MATRIX_MV, i.vertex);
				float3 vs_light_pos = mul(UNITY_MATRIX_V, light_pos);
				float3 vs_camera_pos = mul(UNITY_MATRIX_V, camera_pos).xyz;
				float3 vs_n = normalize(vs_normal);
				float3 vs_l = normalize(vs_light_pos - vs_pos);
				float3 vs_v = normalize(vs_camera_pos - vs_pos);

				float rough = roughness * roughness;
				float A = 1 - 0.5 * rough / (rough + 0.33);
				float B = 0.45 * rough / (rough + 0.09);
				float L = saturate(dot(vs_n, vs_l));
				float V = saturate(dot(vs_n, vs_v));
				float C = sqrt((1 - L * L) * (1 - V * V)) / max(L, V);
				float P = saturate(dot(normalize(vs_l - vs_n * L), normalize(vs_v - vs_n * V)));

				float r_diffuse = k_diffuse * L * (A + B * (P * C));

				o.vertex = UnityObjectToClipPos(i.vertex);
				o.color = _Color * r_diffuse + k_ambient;
				return o;
			}

			float4 frag(v2f i) :SV_TARGET{
				return i.color;
			}
			ENDCG
		}
	}
}