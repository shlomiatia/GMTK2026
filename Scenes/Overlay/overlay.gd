class_name Overlay extends CanvasLayer

signal continue_pressed
signal restart_pressed

enum EndState { NONE, WON, LOST }

var _end_state: EndState = EndState.NONE

@onready var _message_label: Label = $MessageLabel


func show_win() -> void:
	_end_state = EndState.WON
	_message_label.text = "You win! Press any key continue"
	_message_label.visible = true
	get_tree().paused = true


func show_lose() -> void:
	_end_state = EndState.LOST
	_message_label.text = "You lose! Press R to restart"
	_message_label.visible = true
	get_tree().paused = true


func hide_message() -> void:
	_end_state = EndState.NONE
	_message_label.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if _end_state == EndState.NONE || !event.is_pressed() || event.is_echo():
		return
	if _end_state == EndState.WON:
		continue_pressed.emit()
	elif event.is_action("restart"):
		get_tree().paused = false
		restart_pressed.emit()
