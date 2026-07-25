extends CanvasLayer

@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _color_rect: ColorRect = $ColorRect


func transition_to_scene(path: String) -> void:
	_animation_player.play("fade_out")
	await _animation_player.animation_finished
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	if !get_tree().get_nodes_in_group("boss").is_empty():
		(_color_rect.material as ShaderMaterial).set_shader_parameter("progress", 0.0)
		return
	_animation_player.play("fade_in")
	await _animation_player.animation_finished
	get_tree().paused = false
