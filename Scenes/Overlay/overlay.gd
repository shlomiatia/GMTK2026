class_name Overlay extends CanvasLayer

@onready var _attempts_label: Label = $AttemptsLabel
@onready var _message_label: Label = $MessageLabel


func set_attempts(value: int) -> void:
	_attempts_label.text = "Attempts: %d" % value


func show_message(text: String) -> void:
	_message_label.text = text
	_message_label.visible = true
