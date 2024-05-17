extends Node

const REFERENCE_RESOLUTION = Vector2i(640, 360)
const DESKTOP_MAX_WINDOW_SCALE = 6

static var VERSION = ProjectSettings.get_setting("application/config/version")
static var IS_WEB_VERSION = OS.has_feature("web")


var _fullscreen: bool:
	get: return _fullscreen

	set(value):
		_fullscreen = value

		if _fullscreen:
			_window.mode = Window.MODE_EXCLUSIVE_FULLSCREEN
		else:
			_window.mode = Window.MODE_WINDOWED

			var scale := 1

			for i in range(1, DESKTOP_MAX_WINDOW_SCALE):
				if REFERENCE_RESOLUTION * i < DisplayServer.screen_get_size():
					scale = i
				else:
					break

			_window.size = REFERENCE_RESOLUTION * scale

			_window.position = (
				DisplayServer.screen_get_size() / 2 - _window.size / 2)


var _play_music: bool:
	get: return _play_music

	set(value):
		_play_music = value
		_music.play() if _play_music else _music.stop()


var _free_camera_mode: bool:
	get: return _free_camera_mode

	set(value):
		_free_camera_mode = value
		_free_camera.camera.current = value
		_orbit_camera.camera.current = not value


var _show_menu: bool:
	get: return _show_menu

	set(value):
		_show_menu = value
		_menu.visible = _show_menu

		_planar_layer.mouse_filter = (
			Control.MOUSE_FILTER_STOP if _show_menu else Control.MOUSE_FILTER_IGNORE)

		if not IS_WEB_VERSION:
			Input.mouse_mode = (
				Input.MOUSE_MODE_VISIBLE if _show_menu else Input.MOUSE_MODE_CAPTURED)


var _active_sample_index: int:
	get: return _active_sample_index

	set(value):
		_active_sample_index = wrapi(value, 0, _samples.get_child_count())

		for sample: Node3D in _samples.get_children():
			sample.visible = sample.get_index() == _active_sample_index


var _pixelation_intensity: int:
	get: return _pixelation_intensity

	set(value):
		_pixelation_intensity = wrapi(value, 0, DESKTOP_MAX_WINDOW_SCALE)
		_spatial_layer.stretch_shrink = _pixelation_intensity + 1


var _low_color_depth: bool:
	get: return _low_color_depth

	set(value):
		_low_color_depth = value
		_spatial_layer_material.set_shader_parameter("color_depth", 24 if _low_color_depth else 0)


var _vertex_snap_intensity: int:
	get: return _vertex_snap_intensity

	set(value):
		_vertex_snap_intensity = wrapi(value, 0, 3)

		RenderingServer.global_shader_parameter_set(
			"vertex_snap_intensity", _vertex_snap_intensity)


var _affine_texture_mapping: bool:
	get: return _affine_texture_mapping

	set(value):
		_affine_texture_mapping = value

		RenderingServer.global_shader_parameter_set(
			"affine_texture_mapping", _affine_texture_mapping)


var _texture_filtering: bool:
	get: return _texture_filtering

	set(value):
		_texture_filtering = value

		RenderingServer.global_shader_parameter_set(
			"texture_filtering", _texture_filtering)


@onready
var _window: Window = get_tree().root

@onready
var _music: AudioStreamPlayer = $Music

@onready
var _spatial_layer: SubViewportContainer = $SpatialLayer

@onready
var _spatial_layer_material: ShaderMaterial = _spatial_layer.material as ShaderMaterial

@onready
var _free_camera: FreeCamera = %FreeCamera

@onready
var _orbit_camera: OrbitCamera = %OrbitCamera

@onready
var _floor: MeshInstance3D = %Floor

@onready
var _samples: Node3D = %Samples

@onready
var _planar_layer: SubViewportContainer = $PlanarLayer

@onready
var _title_label: RichTextLabel = %Title

@onready
var _camera_info_label: RichTextLabel = %CameraInfo

@onready
var _camera_info_label_base_text := _camera_info_label.text

@onready
var _menu_visibility_indicator: RichTextLabel = %MenuVisibilityIndicator

@onready
var _menu_visibility_indicator_base_text := _menu_visibility_indicator.text

@onready
var _menu: VBoxContainer = %Menu

@onready
var _fullscreen_button: Button = %Fullscreen

@onready
var _fullscreen_button_base_text := _fullscreen_button.text

@onready
var _music_button: Button = %Music

@onready
var _music_button_base_text := _music_button.text

@onready
var _floor_button: Button = %FloorToggle

@onready
var _floor_button_base_text := _floor_button.text

@onready
var _sample_button: Button = %Sample

@onready
var _sample_button_base_text := _sample_button.text

@onready
var _pixelation_intensity_button: Button = %PixelationIntensity

@onready
var _pixelation_intensity_button_base_text := _pixelation_intensity_button.text

@onready
var _low_color_depth_button: Button = %LowColorDepth

@onready
var _low_color_depth_button_base_text := _low_color_depth_button.text

@onready
var _vertex_snap_intensity_button: Button = %VertexSnapIntensity

@onready
var _vertex_snap_intensity_button_base_text := _vertex_snap_intensity_button.text

@onready
var _affine_texture_mapping_button: Button = %AffineTextureMapping

@onready
var _affine_texture_mapping_button_base_text := _affine_texture_mapping_button.text

@onready
var _texture_filtering_button: Button = %TextureFiltering

@onready
var _texture_filtering_button_base_text := _texture_filtering_button.text

@onready
var _quit_button: Button = %Quit

@onready
var _fade_overlay: FadeOverlay = $FadeOverlay


func _ready() -> void:
	_window.min_size = REFERENCE_RESOLUTION
	_window.msaa_3d = Viewport.MSAA_DISABLED
	_window.title = "Retro Shaders Demo (v%s)" % VERSION
	_fullscreen = true

	_title_label.text %= VERSION

	_menu_visibility_indicator.visible = not IS_WEB_VERSION
	_fullscreen_button.visible = not IS_WEB_VERSION
	_quit_button.visible = not IS_WEB_VERSION

	_free_camera_mode = false
	_show_menu = true

	_pixelation_intensity = 0
	_low_color_depth = false
	_vertex_snap_intensity = 2
	_affine_texture_mapping = true
	_texture_filtering = false

	await _fade_overlay.fade_out()
	_play_music = true


func _process(_delta: float) -> void:
	if not IS_WEB_VERSION:
		if Input.is_action_just_pressed("toggle_fullscreen"):
			_fullscreen = not _fullscreen

		if Input.is_action_just_pressed("toggle_menu"):
			_show_menu = not _show_menu

		if Input.is_action_just_pressed("toggle_free_camera_mode"):
			_free_camera_mode = not _free_camera_mode

		_menu_visibility_indicator.text = (
			_menu_visibility_indicator_base_text %
			_format_bool(_show_menu, "Hide", "Show"))

		_fullscreen_button.button_pressed = _fullscreen
		_fullscreen_button.text = _fullscreen_button_base_text % _format_bool(_fullscreen)

	if _free_camera_mode:
		_camera_info_label.text = _camera_info_label_base_text % [
			"Speed: %s" % _free_camera.speed,
			"modify: wheel up/down",
			"orbit mode: tab" if not IS_WEB_VERSION else ""
		]
	else:
		_camera_info_label.text = _camera_info_label_base_text % [
			"Orbit Mode: %s" % (
				"OFF" if not _orbit_camera.spin_enabled else
				("[color=yellow]REVERSE" if _orbit_camera.spin_reverse else "[color=aqua]ON")),

			"toggle: space; reverse: shift",
			"free mode: tab" if not IS_WEB_VERSION else ""
		]

	_music_button.button_pressed = _play_music
	_music_button.text = _music_button_base_text % _format_bool(_play_music, "PLAYING", "STOPPED")

	_floor_button.button_pressed = _floor.visible
	_floor_button.text = _floor_button_base_text % _format_bool(_floor.visible, "SHOWN", "HIDDEN")

	_sample_button.text = _sample_button_base_text % [
		_active_sample_index + 1, _samples.get_child_count()]

	_pixelation_intensity_button.text = (
		_pixelation_intensity_button_base_text % _pixelation_intensity)

	_low_color_depth_button.button_pressed = _low_color_depth
	_low_color_depth_button.text = (
		_low_color_depth_button_base_text % _format_bool(_low_color_depth))

	_vertex_snap_intensity_button.text = (
		_vertex_snap_intensity_button_base_text % _vertex_snap_intensity)

	_affine_texture_mapping_button.button_pressed = _affine_texture_mapping
	_affine_texture_mapping_button.text = (
		_affine_texture_mapping_button_base_text % _format_bool(_affine_texture_mapping))

	_texture_filtering_button.button_pressed = _texture_filtering
	_texture_filtering_button.text = (
		_texture_filtering_button_base_text % _format_bool(_texture_filtering))


func _format_bool(value: bool, if_true := "ON", if_false := "OFF") -> String:
	return if_true if value else if_false


func _on_fullscreen_button_toggled(toggled_on: bool) -> void:
	_fullscreen = toggled_on


func _on_music_button_toggled(toggled_on: bool) -> void:
	_play_music = toggled_on


func _on_floor_button_toggled(toggled_on: bool) -> void:
	_floor.visible = toggled_on


func _on_sample_button_pressed() -> void:
	_active_sample_index += 1


func _on_pixelation_intensity_button_pressed() -> void:
	_pixelation_intensity += 1


func _on_low_color_depth_button_toggled(toggled_on: bool) -> void:
	_low_color_depth = toggled_on


func _on_vertex_snap_intensity_button_pressed() -> void:
	_vertex_snap_intensity += 1


func _on_affine_texture_mapping_button_toggled(toggled_on: bool) -> void:
	_affine_texture_mapping = toggled_on


func _on_texture_filtering_button_toggled(toggled_on: bool) -> void:
	_texture_filtering = toggled_on


func _on_quit_button_pressed() -> void:
	await _fade_overlay.fade_in()
	get_tree().quit()
