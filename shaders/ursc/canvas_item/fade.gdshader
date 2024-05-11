#pragma disable_preprocessor

shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_nearest, repeat_disable;

//  1: white
// -1: black
uniform int mode: hint_range(-1, 1, 2) = -1;

void fragment()
{
	vec3 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	COLOR.rgb = screen_color + COLOR.a * float(mode);
	COLOR.a = 1.0;
}