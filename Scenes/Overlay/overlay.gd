class_name Overlay extends CanvasLayer

signal restart_pressed
signal win_confirmed

var _lost: bool = false
var _win_ready: bool = false

@onready var _defeat_image: Sprite2D = $DefeatImage
@onready var _victory_image: Sprite2D = $VictoryImage
@onready var _victory_animation_player: AnimationPlayer = $VictoryImage/AnimationPlayer


func show_lose() -> void:
	_lost = true
	_defeat_image.visible = true
	get_tree().paused = true


func hide_message() -> void:
	_lost = false
	_defeat_image.visible = false


func show_win() -> void:
	_victory_image.visible = true
	_victory_animation_player.play("fade_in")
	await _victory_animation_player.animation_finished
	_win_ready = true


func _unhandled_input(event: InputEvent) -> void:
	if !event.is_pressed() || event.is_echo():
		return
	if _lost && event.is_action("restart"):
		get_tree().paused = false
		restart_pressed.emit()
		return
	if _win_ready && _is_button_event(event):
		_win_ready = false
		win_confirmed.emit()


func _is_button_event(event: InputEvent) -> bool:
	return event is InputEventKey || event is InputEventMouseButton || event is InputEventJoypadButton
