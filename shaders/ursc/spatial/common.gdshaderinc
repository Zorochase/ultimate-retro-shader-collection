// If you want to use fog controlled by a Godot Environment resource (pixel-based),
// simply uncomment the following line:
// #define USE_ENVIRONMENT_FOG

// Render mode
render_mode

#if defined(BLEND_MODE)
	BLEND_MODE,
#endif

#if defined(CULL_MODE)
	CULL_MODE,
#else
	cull_back,
#endif

#if defined(ALPHA_BLEND)
	depth_draw_always,
#else
	depth_draw_opaque,
#endif

#if defined(UNSHADED)
	unshaded,
#else
	diffuse_lambert_wrap,
	vertex_lighting,
#endif

#if defined(AMBIENT_LIGHT_DISABLED)
	ambient_light_disabled,
#endif

#if defined(FOG_DISABLED)
	fog_disabled,
#endif

specular_disabled,
shadows_disabled;


// Constants
#if !defined(OVERRIDE_VERTEX_SNAP_RESOLUTION)
	const ivec2 VERTEX_SNAP_RESOLUTION = ivec2(320, 240);
#endif


// Global uniforms
#if !defined(TEXTURE_DISABLED) && !defined(SHINY)
	#if !defined(TEXTURE_METAL)
		global uniform bool affine_texture_mapping;
	#endif

	global uniform bool texture_filtering;
	global uniform float texture_lod_halve_distance;
#endif

#if defined(OVERRIDE_VERTEX_SNAP_RESOLUTION)
	global uniform ivec2 vertex_snap_resolution;
#else
	global uniform int vertex_snap_intensity;
#endif

#if !defined(FOG_DISABLED) && !defined(USE_ENVIRONMENT_FOG)
	global uniform vec4 fog_color : source_color;
	global uniform float fog_start_distance;
	global uniform float fog_end_distance;
#endif

global uniform float cull_distance;


// Uniforms
#if defined(ALPHA_BLEND) || (defined(ALPHA_SCISSOR) && !defined(SHINY) && !defined(TEXTURE_METAL))
	uniform vec4 albedo_color : source_color = vec4(1.0);
#else
	uniform vec3 albedo_color : source_color = vec3(1.0);
#endif

#if defined(SHINY)
	uniform float color_depth : hint_range(16, 64, 16) = 16;
	uniform float glossiness : hint_range(0, 1, 0.05) = 0.4;
	uniform float shadow_intensity : hint_range(0, 1, 0.05) = 0.65;
#elif !defined(TEXTURE_DISABLED)
	uniform sampler2D albedo_texture :
		source_color,
		filter_nearest,
		#if defined(TEXTURE_REPEAT)
			repeat_enable;
		#else
			repeat_disable;
		#endif

	#if (defined(ALPHA_SCISSOR) && !defined(SHINY) && !defined(TEXTURE_METAL))
		uniform float alpha_scissor : hint_range(0, 1, 0.01) = 0.1;
	#else
		uniform bool albedo_texture_as_primary_color = true;
		uniform float mix_factor: hint_range(0.0, 1.0, 0.01) = 1.0;
	#endif

	uniform float texture_lod_halve_distance_override : hint_range(0.0, 32.0, 2.0) = 0;

	#if !defined(TEXTURE_METAL)
		uniform vec2 uv_offset = vec2(0.0);
		uniform vec2 uv_scale = vec2(1.0);
		uniform vec2 uv_scroll_speed = vec2(0.0);
	#endif
#endif

#if defined(BILLBOARD)
	uniform int billboard_mode: hint_range(0, 2);
	uniform bool use_transform_scale = true;
#endif

uniform float cull_distance_override: hint_range(0.0, 1024.0, 2.0) = 0;

uniform bool convert_vertex_colors = false;


// Varyings
#if !defined(TEXTURE_DISABLED) && !defined(TEXTURE_METAL) && !defined(SHINY)
	varying float position_w;
#endif

#if !defined(TEXTURE_DISABLED) && !defined(SHINY)
	varying flat int should_halve_texture_lod;
#endif

#if !defined(FOG_DISABLED) && !defined(USE_ENVIRONMENT_FOG)
	varying float fog_mix_factor;
#endif

// Functions
#if defined(SHINY)
	vec3 glimmer(vec3 input)
	{
		float grayscale = max(vec3(input).r, max(vec3(input).g, vec3(input).b));
		float lower = floor(grayscale * color_depth) / color_depth;
		float lower_difference = abs(grayscale - lower);
		float upper = ceil(grayscale * color_depth) / color_depth;
		float upper_difference = abs(upper - grayscale);
		float level = lower_difference <= upper_difference ? lower : upper;
		float adjustment = level / grayscale;
		return vec3(input) * adjustment;
	}
#elif !defined(TEXTURE_DISABLED)
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
#endif

void vertex()
{
	if (convert_vertex_colors)
		COLOR.rgb = pow(COLOR.rgb, vec3(1.0 / 2.2));

	#if !defined(TEXTURE_DISABLED) && !defined(TEXTURE_METAL) && !defined(SHINY)
		UV = UV * uv_scale + uv_offset + (uv_scroll_speed * TIME);
	#endif

	#if defined(BILLBOARD)
		if (billboard_mode > 0)
		{
			if (billboard_mode == 1)
			{
				MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
					INV_VIEW_MATRIX[0],
					INV_VIEW_MATRIX[1],
					INV_VIEW_MATRIX[2],
					MODEL_MATRIX[3]);
			}
			else
			{
				MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
					vec4(normalize(cross(vec3(0.0, 1.0, 0.0), INV_VIEW_MATRIX[2].xyz)), 0.0),
					vec4(0.0, 1.0, 0.0, 0.0),
					vec4(normalize(cross(INV_VIEW_MATRIX[0].xyz, vec3(0.0, 1.0, 0.0))), 0.0),
					MODEL_MATRIX[3]);
			}

			if (use_transform_scale)
			{
				MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(
					vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0),
					vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0),
					vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0),
					vec4(0.0, 0.0, 0.0, 1.0));
			}

			MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
		}
	#endif

	float vertex_distance = length((MODELVIEW_MATRIX * vec4(VERTEX, 1.0)));

	#if !defined(FOG_DISABLED) && !defined(USE_ENVIRONMENT_FOG)
		if (fog_start_distance >= 0.0 && fog_start_distance < fog_end_distance)
		{
			fog_mix_factor = clamp(
				(vertex_distance - fog_start_distance) / (fog_end_distance - fog_start_distance),
				0.0, 1.0);
		}
		else
		{
			fog_mix_factor = 0.0;
		}
	#endif

	#if !defined(TEXTURE_DISABLED) && !defined(SHINY)
		float actual_texture_lod_halve_distance =
			texture_lod_halve_distance_override > 0.0
				? texture_lod_halve_distance_override
				: texture_lod_halve_distance;

		should_halve_texture_lod = (
			!texture_filtering &&
			actual_texture_lod_halve_distance > 0.0 &&
			vertex_distance > actual_texture_lod_halve_distance) ? 1 : 0;
	#endif

	float actual_cull_distance =
		cull_distance_override > 0.0 ? cull_distance_override : cull_distance;

	if (actual_cull_distance > 0.0 && vertex_distance > actual_cull_distance)
	{
		POSITION = vec4(sqrt(-1));
	}
	else
	{
		POSITION = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0);

		#if defined(OVERRIDE_VERTEX_SNAP_RESOLUTION)
			vec4 snapped_position = POSITION;
			snapped_position.xyz = POSITION.xyz / POSITION.w;

			vec2 actual_vertex_snap_resolution = vec2(vertex_snap_resolution);

			snapped_position.x =
				floor(actual_vertex_snap_resolution.x * snapped_position.x) /
				actual_vertex_snap_resolution.x;

			snapped_position.y =
				floor(actual_vertex_snap_resolution.y * snapped_position.y) /
				actual_vertex_snap_resolution.y;

			snapped_position.xyz *= POSITION.w;

			POSITION.xyz = snapped_position.xyz;
		#else
			if (vertex_snap_intensity > 0 && vertex_snap_intensity <= 2)
			{
				vec2 real_vertex_snap_resolution =
					vec2(VERTEX_SNAP_RESOLUTION) * (1.0 / float(vertex_snap_intensity));

				vec4 snapped_position = POSITION;
				snapped_position.xyz = POSITION.xyz / POSITION.w;

				snapped_position.x =
					floor(real_vertex_snap_resolution.x * snapped_position.x) /
					real_vertex_snap_resolution.x;

				snapped_position.y =
					floor(real_vertex_snap_resolution.y * snapped_position.y) /
					real_vertex_snap_resolution.y;

				snapped_position.xyz *= POSITION.w;

				POSITION.xyz = snapped_position.xyz;
			}
		#endif
	}

	#if !defined(TEXTURE_DISABLED) && !defined(TEXTURE_METAL) && !defined(SHINY)
		if (affine_texture_mapping)
		{
			position_w = POSITION.w;
			UV *= abs(POSITION.w);
		}
	#endif
}

void fragment()
{
	#if defined(SHINY)
		vec3 light_dir = vec3(0.500000, 0.250000, 1.000000);
		float light_dot = dot(light_dir, NORMAL);
		vec3 brightness = glimmer(vec3(pow(light_dot, 10.0)));
		brightness = clamp(brightness * vec3(glossiness), vec3(0.00000), vec3(1.00000));
		vec3 shadow_dir = vec3(-light_dir.x, -light_dir.y, light_dir.z);
		float dark_dot = dot(NORMAL, shadow_dir);
		vec3 darkness = glimmer(vec3(dark_dot));

		ALBEDO =
			clamp(albedo_color.rgb +
			brightness +
			darkness * vec3(-shadow_intensity), 0.0, 1.0);

		#if defined(ALPHA_BLEND)
			ALPHA = albedo_color.a;
		#endif
	#else
		#if defined(TEXTURE_DISABLED)
			ALBEDO = albedo_color.rgb * COLOR.rgb;

			#if defined(ALPHA_BLEND)
				ALPHA = albedo_color.a * COLOR.a;
			#endif
		#else
			vec2 uv;

			#if defined(TEXTURE_METAL)
				uv = vec2(NORMAL.x / 2.0 + 0.5, (-NORMAL.y) / 2.0 + 0.5);
			#else
				uv = UV;

				if (affine_texture_mapping)
					uv /= abs(position_w);
			#endif

			vec4 sampled_color;

			if (should_halve_texture_lod == 1)
			{
				vec2 half_albedo_texture_size = vec2(textureSize(albedo_texture, 0)) * 0.5;
				vec2 new_uv = floor(uv * half_albedo_texture_size) / half_albedo_texture_size;

				sampled_color = texture(albedo_texture, new_uv);
			}
			else
			{
				if (texture_filtering)
					sampled_color = albedoTextureFiltered(uv);
				else
					sampled_color = texture(albedo_texture, uv);
			}

			#if (defined(ALPHA_SCISSOR) && !defined(SHINY) && !defined(TEXTURE_METAL))
				ALBEDO = albedo_color.rgb * sampled_color.rgb;
				ALPHA = albedo_color.a * sampled_color.a;
				ALPHA_SCISSOR_THRESHOLD = alpha_scissor;
			#else
				vec3 primary_color =
					albedo_texture_as_primary_color ? sampled_color.rgb : COLOR.rgb;

				vec3 secondary_color =
					albedo_texture_as_primary_color ? COLOR.rgb : sampled_color.rgb;

				ALBEDO =
					(1.0 - mix_factor) * primary_color +
					mix_factor * secondary_color * primary_color;

				ALBEDO *= albedo_color.rgb;

				#if defined(ALPHA_BLEND)
					ALPHA = albedo_color.a * sampled_color.a * COLOR.a;
				#endif
			#endif
		#endif
	#endif

	#if !defined(FOG_DISABLED) && !defined(USE_ENVIRONMENT_FOG)
		FOG.a = fog_mix_factor;
		FOG.rgb = fog_color.rgb;
	#endif
}