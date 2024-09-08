shader_type spatial;
//render_mode cull_disabled;

uniform sampler2D base_tex: source_color;
uniform vec3 grass_uv_scale = vec3(1.0);

uniform sampler2D grass_noise_tex;
uniform float grass_noise_size;
uniform vec3 grass_noise_uv_scale = vec3(1.0);

uniform sampler2D grass_alpha_tex;
uniform vec3 grass_alpha_uv_scale = vec3(1.0);

uniform float wind_sway_frequency = 0.75;
uniform float wind_sway_amplitude = 0.5;

varying vec3 v_position;
varying vec3 v_normal;
varying float v_height;

void vertex() {
	// Called for every vertex the material is visible on.
	v_position = VERTEX;
	v_normal = NORMAL;
	v_height = INSTANCE_CUSTOM.r;
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
	vec3 pos_offset = wind_sway_amplitude * pow(v_height, 4) * vec3(cos(t), sin(t), sin(t));

	vec3 grass_noise = triplanerTexture(grass_noise_tex, v_position + (pos_offset * grass_noise_uv_scale), v_normal, grass_noise_uv_scale);
	//grass_noise = texture(grass_noise_tex, UV).rgb;
	//grass_noise = vec3(triplanarGridAlpha(v_position, v_normal, grass_noise_uv_scale));
	float grass_alpha = triplanerTexture(grass_alpha_tex, v_position, v_normal, grass_alpha_uv_scale).r;
	ALPHA = grass_noise.r * step(0.3, grass_alpha);
	//ALPHA = grass_noise.r * triplanarGridAlpha(v_position, v_normal, grass_noise_uv_scale);
	ALPHA_SCISSOR_THRESHOLD = v_height + 0.001;

	//vec3 albedo_multipler = mix(base_color, tip_color, height_normalized);
	//ALBEDO = texture(base_tex, UV * grass_uv_scale.xy + pos_offset.xy).rgb;
	vec3 ao = mix(vec3(0.4), vec3(1.0), v_height);
	ALBEDO = triplanerTexture(base_tex, v_position + (pos_offset * grass_uv_scale), v_normal, grass_uv_scale).rgb * ao;
}

//float triplanarGridAlpha(vec3 frag_pos, vec3 frag_norm, vec3 uv_scale) {
	//vec2 uvx = frag_pos.yz * uv_scale.yz;
	//vec2 uvy = frag_pos.xz * uv_scale.xz;
	//vec2 uvz = frag_pos.xy * uv_scale.xy;
//
	//vec2 uvx_alpha = fract(uvx * grass_noise_size);
	//vec2 uvy_alpha = fract(uvy * grass_noise_size);
	//vec2 uvz_alpha = fract(uvz * grass_noise_size);
//
	//vec3 blend_norm = frag_norm;
	//blend_norm = abs(blend_norm);
	//blend_norm /= dot(blend_norm, vec3(1.0));
	//float p = 1.0;
	//blend_norm = vec3(pow(blend_norm.x, p), pow(blend_norm.y, p), pow(blend_norm.z, p));
//
	//vec2 grid_alpha_blend = uvx_alpha * blend_norm.x + uvy_alpha * blend_norm.y + uvz_alpha * blend_norm.z;
	//float grid_alpha = length(grid_alpha_blend * 2.0 - 1.0);
	//float p1 = 0.3;
	//grid_alpha = pow(abs(grid_alpha - 1.0), p1);
//
	//return grid_alpha;
//}