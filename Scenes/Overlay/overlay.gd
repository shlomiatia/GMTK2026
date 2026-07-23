class_name Overlay extends CanvasLayer

@onready var _time_label: Label = $TimeLabel
@onready var _message_label: Label = $MessageLabel


func set_time(value: float) -> void:
	_time_label.text = "Time: %d" % ceili(value)


func show_message(text: String) -> void:
	_message_label.text = text
	_message_label.visible = true


func hide_message() -> void:
	_message_label.visible = false
