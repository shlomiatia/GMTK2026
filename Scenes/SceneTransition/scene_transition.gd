extends CanvasLayer

@onready var _animation_player: AnimationPlayer = $AnimationPlayer


func transition_to_scene(path: String) -> void:
	_animation_player.play("fade_out")
	await _animation_player.animation_finished
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	_animation_player.play("fade_in")
	await _animation_player.animation_finished
	get_tree().paused = false
