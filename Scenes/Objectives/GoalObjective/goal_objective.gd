class_name GoalObjective extends Node

signal completed

@onready var _goal: Goal = get_tree().get_first_node_in_group("goal")


func _ready() -> void:
    _goal.car_entered.connect(_on_car_entered)


func _on_car_entered() -> void:
    completed.emit()
