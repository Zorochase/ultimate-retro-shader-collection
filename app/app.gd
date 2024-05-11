extends Node


const REFERENCE_RESOLUTION = Vector2i(640, 360)
const ABSOLUTE_MAX_WINDOW_SCALE = 6

static var VERSION = ProjectSettings.get_setting("application/config/version")


@export
var _fullscreen := true

@export
var _play_music_on_startup := true


var _show_menu: bool:
	get: return _show_menu

	set(value):
		_show_menu = value

		_menu.visible = _show_menu

		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if _show_menu else Input.MOUSE_MODE_CAPTURED

		_planar_layer.mouse_filter = (
			Control.MOUSE_FILTER_STOP if _show_menu else Control.MOUSE_FILTER_IGNORE)


var _play_music: bool:
	get: return _play_music

	set(value):
		_play_music = value
		_music.play() if _play_music else _music.stop()


var _active_sample_index: int:
	get: return _active_sample_index

	set(value):
		_active_sample_index = wrapi(value, 0, _samples.get_child_count())

		for sample: Node3D in _samples.get_children():
			sample.visible = sample.get_index() == _active_sample_index


var _pixelation_intensity: int:
	get: return _pixelation_intensity

	set(value):
		_pixelation_intensity = wrapi(value, 0, ABSOLUTE_MAX_WINDOW_SCALE)
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
var _player: Player = %Player

@onready
var _samples: Node3D = %Samples

@onready
var _planar_layer: SubViewportContainer = $PlanarLayer

@onready
var _title_label: RichTextLabel = %Title

@onready
var _speed_indicator_label: RichTextLabel = %SpeedIndicator

@onready
var _speed_indicator_label_base_text := _speed_indicator_label.text

@onready
var _menu: VBoxContainer = %Menu

@onready
var _sample_button: Button = %Sample

@onready
var _fullscreen_button: Button = %Fullscreen

@onready
var _fullscreen_button_base_text := _fullscreen_button.text

@onready
var _music_button: Button = %Music

@onready
var _music_button_base_text := _music_button.text

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
var _fade_overlay: FadeOverlay = $FadeOverlay


func _ready() -> void:
	_show_menu = false

	_window.min_size = REFERENCE_RESOLUTION
	_window.msaa_3d = Viewport.MSAA_DISABLED
	_window.title = "Retro Shaders Demo (v%s)" % VERSION
	_update_window()

	_title_label.text %= VERSION

	_active_sample_index = 0

	_pixelation_intensity = 0
	_low_color_depth = false

	_vertex_snap_intensity = 2
	_affine_texture_mapping = true
	_texture_filtering = false

	await _fade_overlay.fade_out()

	_play_music = _play_music_on_startup


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_fullscreen"):
		_fullscreen = not _fullscreen
		_update_window()

	if Input.is_action_just_pressed("toggle_menu"):
		_show_menu = not _show_menu

	_speed_indicator_label.text = _speed_indicator_label_base_text % _player.speed

	_fullscreen_button.button_pressed = _fullscreen
	_fullscreen_button.text = _fullscreen_button_base_text % _format_bool(_fullscreen)

	_music_button.button_pressed = _play_music
	_music_button.text = _music_button_base_text % _format_bool(_play_music, "playing", "stopped")

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


func _update_window() -> void:
	if _fullscreen:
		_window.mode = Window.MODE_EXCLUSIVE_FULLSCREEN
	else:
		_window.mode = Window.MODE_WINDOWED

		var scale := 1

		for i in range(1, ABSOLUTE_MAX_WINDOW_SCALE):
			if REFERENCE_RESOLUTION * i < DisplayServer.screen_get_size():
				scale = i
			else:
				break

		_window.size = REFERENCE_RESOLUTION * scale

		_window.position = (
			DisplayServer.screen_get_size() / 2 - _window.size / 2)


func _format_bool(value: bool, if_true := "on", if_false := "off") -> String:
	return (if_true if value else if_false).to_upper()


func _on_close_menu_button_pressed() -> void:
	_show_menu = false


func _on_fullscreen_button_toggled(toggled_on: bool) -> void:
	_fullscreen = toggled_on
	_update_window()


func _on_music_button_toggled(toggled_on: bool) -> void:
	_play_music = toggled_on


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
