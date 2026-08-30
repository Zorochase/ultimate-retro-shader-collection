#if !defined(TEXTURE_DISABLED)
	vec4 texture_filtered(sampler2D tex, vec2 uv) {
		vec2 tex_size = vec2(textureSize(tex, 0));

		vec2 tex_pix_a = vec2(1.0 / tex_size.x, 0.0);
		vec2 tex_pix_b = vec2(0.0, 1.0 / tex_size.y);
		vec2 tex_pix_c = vec2(tex_pix_a.x,tex_pix_b.y);
		vec2 half_tex = vec2(tex_pix_a.x * 0.5, tex_pix_b.y * 0.5);
		vec2 uv_centered = uv - half_tex;

		vec4 diffuse_color = texture(tex, uv_centered);
		vec4 sample_a = texture(tex, uv_centered + tex_pix_a);
		vec4 sample_b = texture(tex, uv_centered + tex_pix_b);
		vec4 sample_c = texture(tex, uv_centered + tex_pix_c);

		float interp_x = modf(uv_centered.x * tex_size.x, tex_size.x);
		float interp_y = modf(uv_centered.y * tex_size.y, tex_size.y);

		if (uv_centered.x < 0.0) {
			interp_x = 1.0 - interp_x * -1.0;
		}

		if (uv_centered.y < 0.0) {
			interp_y = 1.0 - interp_y * -1.0;
		}

		diffuse_color = (
			diffuse_color +
			interp_x * (sample_a - diffuse_color) +
			interp_y * (sample_b - diffuse_color)) *
			(1.0 - step(1.0, interp_x + interp_y));

		diffuse_color += (
			(sample_c + (1.0 - interp_x) * (sample_b - sample_c) +
			(1.0 - interp_y) * (sample_a - sample_c)) *
			step(1.0, interp_x + interp_y));

		return diffuse_color;
	}
#endif

// https://gamedev.stackexchange.com/a/194038
vec3 linear_to_srgb(vec3 linear_color) {
	bvec3 cutoff = lessThan(linear_color.rgb, vec3(0.0031308));
	vec3 higher = vec3(1.055) * pow(linear_color.rgb, vec3(1.0 / 2.4)) - vec3(0.055);
	vec3 lower = linear_color.rgb * vec3(12.92);

	return mix(higher, lower, cutoff);
}

// https://gamedev.stackexchange.com/a/194038
vec3 srgb_to_linear(vec3 srgb_color) {
	bvec3 cutoff = lessThan(srgb_color.rgb, vec3(0.04045));
	vec3 higher = pow((srgb_color.rgb + vec3(0.055)) / vec3(1.055), vec3(2.4));
	vec3 lower = srgb_color.rgb / vec3(12.92);

	return mix(higher, lower, cutoff);
}