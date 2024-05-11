#pragma disable_preprocessor

shader_type canvas_item;

// 0: bypass
uniform float color_depth: hint_range(0, 32, 8) = 24;

uniform sampler2D dithering_pattern_texture:
	hint_default_white, repeat_enable, filter_nearest;

void fragment()
{
	vec3 base_color = texture(TEXTURE, UV).rgb;

	if (color_depth > 0.0)
	{
		vec2 dpt_size = vec2(textureSize(dithering_pattern_texture, 0));
		vec2 texture_size = vec2(textureSize(TEXTURE, 0));

		vec3 dithering = texture(
			dithering_pattern_texture, UV * (texture_size / dpt_size)).rgb - 0.5;

		COLOR.rgb = round(
			base_color.rgb * color_depth + dithering) / color_depth;
	}
	else
	{
		COLOR.rgb = base_color;
	}
}