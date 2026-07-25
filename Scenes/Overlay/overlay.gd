class_name Overlay extends CanvasLayer

signal restart_pressed

var _lost: bool = false

@onready var _message_label: Label = $MessageLabel


func show_lose() -> void:
	_lost = true
	_message_label.text = "You lose! Press R to restart"
	_message_label.visible = true
	get_tree().paused = true


func hide_message() -> void:
	_lost = false
	_message_label.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if !_lost || !event.is_pressed() || event.is_echo():
		return
	if event.is_action("restart"):
		get_tree().paused = false
		restart_pressed.emit()
