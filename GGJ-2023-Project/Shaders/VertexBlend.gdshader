shader_type spatial;

uniform sampler2D tex1;
uniform vec4 tex1_color : source_color;
uniform float tex1_scale = 1;
uniform sampler2D tex2;
uniform vec4 tex2_color : source_color;
uniform float tex2_scale = 1;
uniform float threshold = 0.5;
uniform float smoothing : hint_range(0.0, 1.0) = 0;
uniform float edge_width = 0.1;
uniform vec3 edge_color : source_color;
uniform float edge_smoothing : hint_range(0.0, 1.0) = 0;
uniform sampler2D noise;
uniform float noise_scale = 1;

varying vec2 uv;
varying vec4 vert_col;

void vertex() {
	uv = VERTEX.xz / 2.0 + 0.5;
	vert_col = COLOR;
}

void fragment() {
	vec3 noise_tex = texture(noise, uv * noise_scale).xyz;
	
	//float t1_factor = step(threshold * noise_tex.r, vert_col.r);
	float t1_factor = smoothstep(threshold * noise_tex.r, threshold * noise_tex.r + edge_smoothing, vert_col.r);
	vec3 t1_col = texture(tex1, uv * tex1_scale).xyz * tex1_color.rgb;
	float edge = smoothstep((threshold - edge_width) * noise_tex.r, (threshold - edge_width) * noise_tex.r + smoothing, vert_col.r) * (1.0 - t1_factor);
	float t2_factor = 1.0 - (t1_factor + edge);
	vec3 t2_col = texture(tex2, uv * tex2_scale).rgb * tex2_color.rgb;
	
	
	ALBEDO = (t1_col * t1_factor) + (edge * edge_color) + (t2_col * t2_factor);
}
