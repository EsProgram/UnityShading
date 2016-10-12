Shader "Custom/VertDisplace" {
	Properties{
		_MainTex("Base (RGB)", 2D) = "white" {}
	}
		SubShader{
		Tags{ "RenderType" = "Opaque" }
		LOD 200

		CGPROGRAM
		// Upgrade NOTE: excluded shader from OpenGL ES 2.0 because it does not contain a surface program or both vertex and fragment programs.
#pragma exclude_renderers gles
#pragma glsl
#pragma target 3.0
#pragma vertex vert
#pragma surface surf BlinnPhong

		sampler2D _MainTex;

	struct Input {
		float2 uv_MainTex;
	};

	void vert(inout appdata_full v) {
		float4 tex = tex2Dlod(_MainTex, float4(v.texcoord.xy,0,0));
		v.vertex.y += tex.r * 2.0;
	}

	void surf(Input IN, inout SurfaceOutput o) {
		half4 tex = tex2D(_MainTex, IN.uv_MainTex);
		o.Albedo = tex.rgb;
		o.Alpha = tex.a;
	}

	ENDCG
	}
		FallBack "Diffuse"
}