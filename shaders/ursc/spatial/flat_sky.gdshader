shader_type spatial;
render_mode unshaded;

#include "utilities.gdshaderinc"

global uniform bool texture_filtering;

uniform sampler2D albedo_texture : source_color, filter_nearest, repeat_enable;
uniform vec2 uv_offset = vec2(0.0);
uniform vec2 uv_scale = vec2(1.0);
uniform vec2 uv_scroll_speed = vec2(0.0);

void fragment() {
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

	if (texture_filtering) {
		ALBEDO = texture_filtered(albedo_texture, uv).rgb;
	} else {
		ALBEDO = texture(albedo_texture, uv).rgb;
	}
}
