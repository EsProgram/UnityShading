Shader "Unlit/Gause"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_N ("n", Float) = 1
		_U ("u", Float) = 1
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
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _N;
			float _U;

			float3 Hue( float hue )
			{
				float3 rgb = frac(hue + float3(0, 0.667, 0.334));
				rgb = abs(rgb * 2 - 1);
				return clamp(rgb * 3 - 1, 0, 1);
			}

			float SphericalGaussian(float3 w, float3 e, float n, float u)
			{
				return u * exp(max(n, 0.001) * (dot(e, w) - 1));
			}

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.n = UnityObjectToWorldNormal(v.n);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float g = SphericalGaussian(normalize(i.n), float3(0, 1, 0), _N, _U);
				//float3 h = clamp(tex2D(_MainTex, float2(g, 1 - g)), 0, 1);
				float3 h = clamp(Hue(g), 0, 1);
				return float4(h.x, h.y, h.z, 1);
			}
			ENDCG
		}
	}
}
