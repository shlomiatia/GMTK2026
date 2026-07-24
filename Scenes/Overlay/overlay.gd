class_name Overlay extends CanvasLayer

@onready var _message_label: Label = $MessageLabel


func show_message(text: String) -> void:
	_message_label.text = text
	_message_label.visible = true


func hide_message() -> void:
	_message_label.visible = false
