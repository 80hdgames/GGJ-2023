shader_type spatial;

uniform sampler2D tex;
instance uniform vec4 tint :source_color = vec4(1,1,1,1);

void fragment() 
{
	vec3 texRgb = texture(tex, UV).rgb;
	ALBEDO = texRgb * tint.rgb;
}
