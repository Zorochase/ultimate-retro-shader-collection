class_name OrbitCamera
extends FloatAndSpin


@onready
var camera: Camera3D = $Camera


func _process(_delta: float) -> void:
	if not camera.current:
		return

	if Input.is_action_just_pressed("toggle_orbit"):
		spin_enabled = not spin_enabled

	if Input.is_action_just_pressed("flip_spin_direction") and spin_enabled:
		spin_reverse = not spin_reverse
