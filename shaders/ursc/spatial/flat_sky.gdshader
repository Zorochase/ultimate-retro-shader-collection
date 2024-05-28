shader_type spatial;
render_mode unshaded;

global uniform bool texture_filtering;

uniform sampler2D albedo_texture : source_color, filter_nearest, repeat_enable;
uniform vec2 uv_offset = vec2(0.0);
uniform vec2 uv_scale = vec2(1.0);
uniform vec2 uv_scroll_speed = vec2(0.0);

vec4 albedoTextureFiltered(vec2 uv)
{
	vec2 albedo_texture_size = vec2(textureSize(albedo_texture, 0));

	vec2 tex_pix_a = vec2(1.0 / albedo_texture_size.x, 0.0);
	vec2 tex_pix_b = vec2(0.0, 1.0 / albedo_texture_size.y);
	vec2 tex_pix_c = vec2(tex_pix_a.x,tex_pix_b.y);
	vec2 half_tex = vec2(tex_pix_a.x * 0.5, tex_pix_b.y * 0.5);
	vec2 uv_centered = uv - half_tex;

	vec4 diffuse_color = texture(albedo_texture, uv_centered);
	vec4 sample_a = texture(albedo_texture, uv_centered + tex_pix_a);
	vec4 sample_b = texture(albedo_texture, uv_centered + tex_pix_b);
	vec4 sample_c = texture(albedo_texture, uv_centered + tex_pix_c);

	float interp_x = modf(uv_centered.x * albedo_texture_size.x, albedo_texture_size.x);
	float interp_y = modf(uv_centered.y * albedo_texture_size.y, albedo_texture_size.y);

	if (uv_centered.x < 0.0)
	{
		interp_x = 1.0 - interp_x * -1.0;
	}
	if (uv_centered.y < 0.0)
	{
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

void fragment()
{
	float y = atan(VIEW_MATRIX[0][2], VIEW_MATRIX[2][2]);
	float x = asin(VIEW_MATRIX[1][2]);

	vec2 bg_coordinates = (vec2(y * 0.5, -x) * -(1.0 / PI)) + 0.5;
	bg_coordinates.y *= 0.5;

	vec2 bg_scale;

	bg_scale.y = 0.5;

	vec2 albedo_texture_size = vec2(textureSize(albedo_texture, 0));
	float aspect_ratio = albedo_texture_size.x / albedo_texture_size.y;
	bg_scale.x = VIEWPORT_SIZE.x / (VIEWPORT_SIZE.y * aspect_ratio) * bg_scale.y;

	vec2 uv = (
		SCREEN_UV * uv_scale + uv_offset + (uv_scroll_speed * TIME)) * bg_scale + bg_coordinates;

	if (texture_filtering)
		ALBEDO = albedoTextureFiltered(uv).rgb;
	else
		ALBEDO = texture(albedo_texture, uv).rgb;
}
