shader_type spatial;

uniform sampler2D base_tex: source_color;
uniform sampler2D normal_tex;
uniform float tex_scale = 1.0;

uniform float wind_sway_frequency = 0.75;
uniform float wind_sway_amplitude = 0.5;

varying vec3 v_position;
varying vec3 v_normal;

void vertex() {
	v_position = VERTEX;
	v_normal = NORMAL;
}

vec3 triplanerTexture(sampler2D tex, vec3 frag_pos, vec3 frag_norm, vec3 uv_scale) {
	vec2 uvx = frag_pos.yz * uv_scale.yz;
	vec2 uvy = frag_pos.xz * uv_scale.xz;
	vec2 uvz = frag_pos.xy * uv_scale.xy;

	vec3 x_axis = texture(tex, uvx).rgb;
    vec3 y_axis = texture(tex, uvy).rgb;
    vec3 z_axis = texture(tex, uvz).rgb;

	vec3 blend_norm = frag_norm;
	blend_norm = abs(blend_norm);
	blend_norm /= dot(blend_norm, vec3(1.0));
	float p = 1.0;
	blend_norm = vec3(pow(blend_norm.x, p), pow(blend_norm.y, p), pow(blend_norm.z, p));

	vec3 texture_blend = x_axis * blend_norm.x + y_axis * blend_norm.y + z_axis * blend_norm.z;

	return texture_blend;
}

void fragment() {
	float t = TIME * wind_sway_frequency;
	vec2 uv_offset = wind_sway_amplitude / tex_scale * vec2(cos(tex_scale * UV.x + t), sin(tex_scale * UV.y + t));

	ALBEDO = texture(base_tex, UV * tex_scale + uv_offset).rgb;
	//NORMAL = texture(normal_tex, UV * tex_scale + uv_offset).rgb;
}
