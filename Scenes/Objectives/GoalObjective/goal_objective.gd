class_name GoalObjective extends Node

signal completed

@onready var _car: Car = get_tree().get_first_node_in_group("car")
@onready var _goal: Goal = get_tree().get_first_node_in_group("goal")


func _ready() -> void:
    _car.rested.connect(_on_car_rested)


func _on_car_rested() -> void:
    if _goal.has_car():
        completed.emit()
