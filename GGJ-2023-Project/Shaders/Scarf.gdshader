shader_type spatial;

uniform sampler2D tex;
instance uniform vec4 tint :source_color = vec4(1,1,1,1);
uniform float rim : hint_range(0.0, 1.0) = 0.1;
uniform float rim_tint : hint_range(0.0, 1.0) = 0.5;

void fragment() 
{
	vec3 texRgb = texture(tex, UV).rgb;
	ALBEDO = texRgb * tint.rgb;
	RIM = rim;
	RIM_TINT = rim_tint;
}
