//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec4 u_Color;

void main()
{
	vec4 col = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);
	gl_FragColor = col * col.a * (1.0 - u_Color.a) + vec4(u_Color.rgb * col.a, col.a) * u_Color.a;
}
