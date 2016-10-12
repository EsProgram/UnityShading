Shader "Unlit/LODTessellation"
{
	Properties{
		_TessFactor("Tess Factor",Vector) = (2,2,2,2)
		_LODFactor("LOD Factor",range(1,10)) = 1
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

				uniform vector _TessFactor;
				uniform float _LODFactor;

				struct appdata {
					float4 w_vert:POSITION;
				};
				struct v2h {
					float4 pos:POS;
				};
				struct h2d_main {
					float3 pos:POS;
				};
				struct h2d_const {
					float tess_factor[3] : SV_TessFactor;
					float InsideTessFactor : SV_InsideTessFactor;
				};
				struct d2f {
					float4 pos:SV_Position;
				};

				struct f_input {
					float4 vertex:SV_Position;
					float4 color:COLOR0;
				};

				v2h VS(appdata i) {
					v2h o = (v2h)0;
					o.pos = i.w_vert;
					return o;
				}

				h2d_const HSConst(InputPatch<v2h, INPUT_PATCH_SIZE> i) {
					h2d_const o = (h2d_const)0;
					//視点からの距離でLODを計算
					float lod = distance(float4(0, 0, 0, 0), mul(UNITY_MATRIX_MV, (i[0].pos + i[1].pos + i[2].pos) / 3));
					o.tess_factor[0] = _TessFactor.x * _LODFactor / lod;
					o.tess_factor[1] = _TessFactor.y * _LODFactor / lod;
					o.tess_factor[2] = _TessFactor.z * _LODFactor / lod;
					o.InsideTessFactor = _TessFactor.w * _LODFactor / lod;
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
					return o;
				}

				[domain("tri")]
				d2f DS(h2d_const hs_const_data, const OutputPatch<h2d_main, OUTPUT_PATCH_SIZE> i, float3 bary:SV_DomainLocation) {
					d2f o = (d2f)0;
					float3 pos = i[0].pos * bary.x + i[1].pos * bary.y + i[2].pos * bary.z;
					o.pos = mul(UNITY_MATRIX_MVP, float4(pos, 1));
					return o;
				}

				float4 FS(f_input i) : SV_Target {
					return float4(1, 0, 0, 1);
				}

				ENDCG
			}
	}
}