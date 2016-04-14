Shader "Custom/MVP" {
	Properties{
		_Color("Color",COLOR) = (1,1,1,1)
	}
	SubShader {
		Pass{
			CGPROGRAM
#pragma vertex vert
#pragma fragment frag

			struct app_data {
				float4 vertex:POSITION;
			};

			struct v2f {
				float4 position:SV_POSITION;
			};

			uniform float4x4 mvp_matrix;
			uniform float4x4 mv_matrix;
			uniform float4x4 v_matrix;

			float4 _Color;

			v2f vert(app_data i) {
				v2f o;
				o.position = mul(mvp_matrix, i.vertex);
				return o;
			}

			float4 frag(v2f i) :SV_TARGET{
				return _Color;
			}

			ENDCG
		}
	}
}
