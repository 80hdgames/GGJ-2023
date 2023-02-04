shader_type spatial;

uniform sampler2D tex;
instance uniform vec4 tint :source_color = vec4(1,1,1,1);
instance uniform vec3 emission;
uniform float rim : hint_range(0.0, 1.0) = 0.1;
uniform float rim_tint : hint_range(0.0, 1.0) = 0.5;
uniform float glow_pulse_speed = 10;

void fragment() 
{
	vec3 texRgb = texture(tex, UV).rgb;
	vec3 glow = emission * (sin(TIME * glow_pulse_speed) * 0.15 + 0.5);
	ALBEDO = texRgb * tint.rgb;
	EMISSION = glow;
	RIM = rim;
	RIM_TINT = rim_tint;
}
