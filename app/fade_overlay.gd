class_name FadeOverlay
extends ColorRect


signal fade_completed


var is_fade_in_progress: bool:
	get:
		return (_animation_player.is_playing() and
		_animation_player.current_animation == "fade")


@onready
var _animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	_animation_player.animation_finished.connect(_on_animation_finished)


func fade_in(duration := 1) -> void:
	_play_fade_animation(duration, false)
	await fade_completed


func fade_out(duration := 1) -> void:
	_play_fade_animation(duration, true)
	await fade_completed


func _play_fade_animation(duration: float, backwards: bool) -> void:
	assert(
		duration >= 0,
		"A transition cannot take a negative amount of time to complete.")

	if is_fade_in_progress:
		_animation_player.pause()

	_animation_player.play(
		"fade", -1, (1.0 / duration) * (-1 if backwards else 1), backwards)


func _on_animation_finished(animation: StringName) -> void:
	if animation != "fade":
		return

	fade_completed.emit()
