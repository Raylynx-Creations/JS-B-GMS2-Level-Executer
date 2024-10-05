//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 texel;

void main()
{
	vec4 blur = vec4(0.0);
	vec2 offset;
	vec2 sample;
	float weight;
	for (offset.x = -1.0; offset.x <= 1.0; offset.x++){
		for (offset.y = -1.0; offset.y <= 1.0; offset.y++){
			sample = clamp(v_vTexcoord + offset * texel, vec2(0.0), vec2(1.0));
			if (offset.x == 0.0 || offset.y == 0.0){
				weight = 0.5;
			}else{
				weight = 0.354;
			}
			blur += weight * texture2D(gm_BaseTexture, sample);
		}
	}
	blur += 3.0 * texture2D(gm_BaseTexture, v_vTexcoord);
	blur /= 6.916;
    gl_FragColor = v_vColour * blur;
}
