Shader "Unlit/Tessellation"
{
	Properties{
		_TessFactor("Tess Factor",Range(1,10)) = 2
	}

		SubShader{
			Pass{
				CGPROGRAM

	#pragma vertex VS
	#pragma fragment FS
	#pragma hull HS
	#pragma domain DS
	#define INPUT_PATCH_SIZE 3
	#define OUTPUT_PATCH_SIZE 3

				uniform float _TessFactor;

				struct appdata {
					float4 vert:POSITION;
					float3 normal:NORMAL;
					float2 uv:TEXCOORD0;
				};
				struct v2h {
					float4 pos:POS;
					float3 normal:NORMAL;
					float2 uv:TEXCOORD0;
				};
				struct h2d_main {
					float3 pos:POS;
					float3 normal:NORMAL;
					float2 uv:TEXCOORD0;
				};
				struct h2d_const {
					float tess_factor[3] : SV_TessFactor;
					float InsideTessFactor : SV_InsideTessFactor;
				};
				struct d2f {
					float4 pos:SV_Position;
					float3 normal:NORMAL;
					float2 uv:TEXCOORD0;
				};

				struct f_input {
					float4 vertex:SV_Position;
					float3 normal:NORMAL;
					float4 color:COLOR0;
					float2 uv:TEXCOORD0;
				};

				v2h VS(appdata i) {
					v2h o = (v2h)0;
					o.pos = i.vert;
					o.normal = i.normal;
					o.uv = i.uv;
					return o;
				}

				h2d_const HSConst(InputPatch<v2h, INPUT_PATCH_SIZE> i) {
					h2d_const o = (h2d_const)0;
					o.tess_factor[0] = _TessFactor;
					o.tess_factor[1] = _TessFactor;
					o.tess_factor[2] = _TessFactor;
					o.InsideTessFactor = _TessFactor;
					return o;
				}

				[domain("tri")]
				[partitioning("integer")]
				[outputtopology("triangle_cw")]
				[outputcontrolpoints(OUTPUT_PATCH_SIZE)]
				[patchconstantfunc("HSConst")]
				h2d_main HS(InputPatch<v2h, INPUT_PATCH_SIZE> i, uint id:SV_OutputControlPointID) {
					h2d_main o = (h2d_main)0;
					o.pos = i[id].pos;
					o.normal = i[id].normal;
					o.uv = i[id].uv;
					return o;
				}

				[domain("tri")]
				d2f DS(h2d_const hs_const_data, const OutputPatch<h2d_main, OUTPUT_PATCH_SIZE> i, float3 bary:SV_DomainLocation) {
					d2f o = (d2f)0;
					o.normal = i[0].normal * bary.x + i[1].normal * bary.y + i[2].normal * bary.z;
					float3 pos = i[0].pos * bary.x + i[1].pos * bary.y + i[2].pos * bary.z;
					o.pos = mul(UNITY_MATRIX_MVP, float4(pos, 1));
					o.uv = i[0].uv * bary.x + i[1].uv * bary.y + i[2].uv * bary.z;
					return o;
				}

				float4 FS(f_input i) : SV_Target {
					return float4(i.normal.x, i.normal.y, i.normal.z, 1);
				}

				ENDCG
			}
	}
}