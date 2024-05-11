extends Node3D


@export
var spin_reverse := false


@export
var float_reverse := false


@export_range(1, 5, 0.1, "or_greater")
var spin_speed := 1.0


@export_range(1, 5, 0.1, "or_greater")
var float_frequency := 1.0


@export_range(0.1, 2, 0.1)
var float_amplitude := 0.5


var _time: float


@onready
var default_position_y = position.y


func _physics_process(delta: float) -> void:
	rotate_y((-1 if spin_reverse else 1) * spin_speed * delta)

	_time += float_frequency * delta

	position.y = default_position_y + sin(_time) * float_amplitude * (-1 if float_reverse else 1)
