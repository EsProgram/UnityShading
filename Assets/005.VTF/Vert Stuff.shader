Shader "Vert Stuff" {
	
Properties {_MainTex ("Texture (Aplha)", 2D) = ""}

SubShader {Pass {
	GLSLPROGRAM
	varying vec4 color;
	
	#ifdef VERTEX
	uniform lowp sampler2D _MainTex;
	float tex(in float x, in float y) {
		return texture2D(_MainTex, gl_MultiTexCoord0.xy + vec2(x,y)).a;
	}
	vec3 spots(in float rx, in float ry, in float gx, in float gy, in float bx, in float by) {
		return vec3(tex(rx, ry), tex(gx, gy), tex(bx, by));
	}
	void main() {
		gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
		color.rgb = 
			spots(0., 0.,	0., .8,		0., .6) +
			spots(.5, 0.,	.5, .8,		.5, .6) +
			spots(.75, .6,	.75, .4,	.75, .2) +
			spots(.25, .6,	.25, .4,	.25, .2);
	}
	#endif
	
	#ifdef FRAGMENT
	void main() {gl_FragColor = color;}
	#endif
	ENDGLSL
}}

}