class_name FreeCamera
extends Node3D


const VERTICAL_LOOK_LIMIT = deg_to_rad(90)

const MIN_SPEED = 1
const MAX_SPEED = 15
const SPEED_INCREMENT = 0.5


@export_range(0.1, 10, 0.1)
var mouse_sensitivity = 2


var speed := 5.0

var is_mouse_captured:
	get: return Input.mouse_mode == Input.MOUSE_MODE_CAPTURED

var _motion_direction := Vector3.ZERO


@onready
var camera: Camera3D = $Camera


func _input(event: InputEvent) -> void:
	if not camera.current:
		return

	if event is InputEventMouseMotion and is_mouse_captured:
		var actual_mouse_sensitivity = mouse_sensitivity * 0.001

		# TODO: remove this in 4.3.
		var actual_relative := get_viewport().get_screen_transform().basis_xform_inv(event.relative)

		rotation.y -= actual_relative.x * actual_mouse_sensitivity
		camera.rotation.x = clamp(
			camera.rotation.x - actual_relative.y * actual_mouse_sensitivity,
			-VERTICAL_LOOK_LIMIT, VERTICAL_LOOK_LIMIT)


func _physics_process(delta: float) -> void:
	if not camera.current:
		return

	var vertical_input := 0.0
	var horizontal_input := Vector2.ZERO

	if is_mouse_captured:
		if Input.is_action_just_released("increase_speed"):
			speed += SPEED_INCREMENT

		if Input.is_action_just_released("decrease_speed"):
			speed -= SPEED_INCREMENT

		vertical_input = (
			(Input.is_action_pressed("move_up") as float) -
			(Input.is_action_pressed("move_down") as float))

		horizontal_input = Input.get_vector(
			"move_left", "move_right", "move_forward", "move_backward")

	speed = clamp(speed, MIN_SPEED, MAX_SPEED)

	_motion_direction = Vector3(
		horizontal_input.x, vertical_input, horizontal_input.y) * speed * delta

	translate(_motion_direction)
