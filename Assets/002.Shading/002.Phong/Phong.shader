Shader "Custom/Phong"{
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
				float4 color:COLOR0;
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
				float3 vs_normal = mul(UNITY_MATRIX_IT_MV, float4(i.normal, 1)); //http://raytracing.hatenablog.com/entry/20130325/1364229762
				float3 vs_light = mul(UNITY_MATRIX_V, light_pos);
				float3 vs_camera = mul(UNITY_MATRIX_V, camera_pos);
				float3 vs_pos = mul(UNITY_MATRIX_MV, i.vertex);
				float3 vs_l = normalize(vs_light - vs_pos);

				float r_diffuse = k_diffuse * max(dot(vs_normal, vs_l), 0);

				float3 vs_v = normalize(vs_camera - vs_pos);
				float3 vs_h = normalize(vs_l + vs_v);

				float r_specular = k_specular * pow(max(dot(vs_normal, vs_h), 0),shininess);

				o.vertex = mul(UNITY_MATRIX_MVP, i.vertex);
				o.color = r_diffuse * _DiffuseColor + r_specular * _SpecularColor + k_ambient;
				return o;
			}

			float4 frag(v2f i) :SV_TARGET{
				return i.color;
			}
			ENDCG
		}
	}
}
