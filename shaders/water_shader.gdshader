shader_type spatial;
//render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;

uniform vec4 albedo_top : source_color = vec4(0.149020, 0.454902, 0.850980, 1.000000);
uniform vec4 albedo_bottom : source_color = vec4(0.149020, 0.454902, 0.850980, 1.000000);
uniform float metallic = 0;
uniform float roughness = 0.30000001192093;

uniform sampler2D inverse_alpha_texture;
uniform vec3 inverse_alpha_texture_scale = vec3(1.0);
uniform float alpha_multiplier = 0.5;

uniform sampler2D ripple_noise_texture;
uniform vec3 ripple_noise_texture_scale = vec3(1.0);
uniform float ripple_noise_blend_sharpness;
uniform vec3 ripple_noise_scale;
uniform vec3 ripple_noise_offset;

uniform float amplitude = 0.05;
uniform float amplitude_power = 1.0;
uniform float frequency = 7.0;
uniform float time_multiplier = 0.001;

varying vec3 v_position;
varying vec3 v_normal;
varying float v_height;

float inverseLerp(float v, float minValue, float maxValue) {
  return (v - minValue) / (maxValue - minValue);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) {
  float t = inverseLerp(v, inMin, inMax);
  return mix(outMin, outMax, t);
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

//vec4 triplanar_texture(sampler2D p_sampler, vec3 p_triplanar_pos, vec3 p_weights) {
	//p_triplanar_pos += sin(p_triplanar_pos.y + time_multiplier * TIME);
	//vec4 samp = vec4(0.0);
	//samp += texture(p_sampler, p_triplanar_pos.xy) * p_weights.z;
	//samp += texture(p_sampler, p_triplanar_pos.xz) * p_weights.y;
	//samp += texture(p_sampler, p_triplanar_pos.zy * vec2(-1.0, 1.0)) * p_weights.x;
	//return samp;
//}

float get_height(vec3 pos, vec3 normal) {
	float t = TIME * frequency;
	vec3 pos_offset = amplitude * vec3(t);
	vec3 ripple_noise = triplanerTexture(ripple_noise_texture, pos + pos_offset, normal, ripple_noise_texture_scale);
	return pow(amplitude * ripple_noise.r, amplitude_power);
}

void vertex() {
	float theta = 0.01;
	vec3 pos_x = VERTEX + TANGENT * vec3(theta);

	vec3 ripple_noise_power_normal = pow(abs(NORMAL), vec3(ripple_noise_blend_sharpness));
	vec3 ripple_noise_triplanar_pos = VERTEX * ripple_noise_scale + ripple_noise_offset;
	ripple_noise_power_normal /= dot(ripple_noise_power_normal, vec3(1.0));
	ripple_noise_triplanar_pos *= vec3(1.0,-1.0, 1.0);

	vec3 ripple_noise_power_normal_x = pow(abs(normalize(pos_x)), vec3(ripple_noise_blend_sharpness));
	vec3 ripple_noise_triplanar_pos_x = pos_x * ripple_noise_scale + ripple_noise_offset;
	ripple_noise_power_normal_x /= dot(ripple_noise_power_normal_x, vec3(1.0));
	ripple_noise_triplanar_pos_x *= vec3(1.0,-1.0, 1.0);

	//VERTEX += NORMAL * get_height(VERTEX, NORMAL);
	//pos_x += normalize(pos_x) * get_height(pos_x, normalize(pos_x));
	
	VERTEX += NORMAL * get_height(ripple_noise_triplanar_pos, ripple_noise_power_normal);
	pos_x += NORMAL * get_height(ripple_noise_triplanar_pos_x, ripple_noise_power_normal_x);

    vec3 dpx = pos_x - VERTEX;

    TANGENT = normalize(dpx);
    BINORMAL = normalize(cross(NORMAL, TANGENT));
    NORMAL = normalize(cross(TANGENT, BINORMAL));

	//v_position = (PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	v_position = VERTEX;
	v_normal = NORMAL;
	v_height = INSTANCE_CUSTOM.r;
}

void fragment() {
	// inverse_alpha_texture is used as the alpha texture
	// by the grass shader. So invert it to make the water
	// visible wherever the grass is not.
	//float alpha = triplanerTexture(inverse_alpha_texture, v_position, v_normal, inverse_alpha_texture_scale).r;
	//alpha = 1.0 - step(0.3, alpha);

	ROUGHNESS = roughness * (1.0 - v_height);
	METALLIC = metallic * (1.0 - v_height);
	//NORMAL = normalize(cross(
		//dFdx(v_position),
		//dFdy(v_position)
	//));
	//float depth_multiplier = 10.0 * pow(texture(depth_texture, SCREEN_UV).r, 1.0);
	ALPHA = alpha_multiplier * (1.0 - v_height);
	ALBEDO = mix(albedo_bottom.rgb, albedo_top.rgb, v_height);
	//ALPHA_SCISSOR_THRESHOLD = 0.3;
	//ALBEDO = albedo_top.rgb;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
