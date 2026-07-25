class_name LevelSkip extends Node

signal skip_requested


func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("skip_level"):
        skip_requested.emit()
