Shader "Custom/PerPixelCookTorranceShader"
{
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
			float4 vertex : POSITION;
			float3 normal : NORMAL;
		};

		struct v2f {
			float4 pos : SV_POSITION;
			float4 local_pos : TEXCOORD0;
			float4 normal : TEXCOORD1;
		};

		uniform float4 light_pos;
		uniform float4 camera_pos;
		uniform float k_diffuse;
		uniform float k_ambient;
		uniform float k_specular;
		uniform float roughness;
		uniform float complex_refractive_index;

		float4 _DiffuseColor;
		float4 _SpecularColor;

		float normal_distribution_function(float d) {
			return 1 / roughness + roughness * pow(cos(d), 4) * exp(-pow((tan(d) / roughness), 2));
		}
		float geometric_attenuation_coefficient(float3 n, float3 v, float3 h, float3 l) {
			float g_out = 2 * dot(n, h) * dot(n, v) / dot(v, h);
			float g_in = 2 * dot(n, h) * dot(n, l) / dot(v, h);
			return min(min(g_in, g_out), 1);
		}

		float fresnel_reflection_coefficient(float phi, float eta) {
			float c = cos(phi);
			float zeta = sqrt(eta * eta + c * c - 1);
			float zpc = zeta + c;
			float zmc = zeta - c;
			return zmc*zmc / zpc*zpc * (1 - (c*zpc - 1)*(c*zpc - 1) / (c*zmc + 1)*(c*zmc + 1));
		}

		v2f vert(app_data i) {
			v2f o;
			o.pos = mul(UNITY_MATRIX_MVP, i.vertex);
			o.local_pos = i.vertex;
			o.normal = mul(UNITY_MATRIX_IT_MV, float4(i.normal, 1));
			return o;
		}

		float4 frag(v2f i) : SV_TARGET{
			float3 vs_light_pos = mul(UNITY_MATRIX_V, light_pos).xyz;
			float3 vs_pos = mul(UNITY_MATRIX_MV, i.local_pos).xyz;
			float3 vs_camera_pos = mul(UNITY_MATRIX_V, camera_pos).xyz;

			float3 vs_n = normalize(i.normal.xyz);
			float3 vs_l = normalize(vs_light_pos - vs_pos);
			float3 vs_v = normalize(vs_camera_pos - vs_pos);
			float3 vs_h = normalize(vs_l + vs_v);

			float r_diffuse = k_diffuse * max(dot(vs_n, vs_l), 0);

			float D = normal_distribution_function(dot(vs_n, vs_h));
			float G = geometric_attenuation_coefficient(vs_n, vs_v, vs_h, vs_l);
			float F = fresnel_reflection_coefficient(dot(vs_n, vs_l), complex_refractive_index);

			float r_specular = k_specular * D * F * G / dot(vs_n, vs_v);

			return r_diffuse * _DiffuseColor + r_specular * _SpecularColor + k_ambient;
		}


		ENDCG
		}
	}
}
