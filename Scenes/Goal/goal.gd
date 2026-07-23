class_name Goal extends Node2D

@onready var _area: Area2D = $Area2D


func has_car() -> bool:
	for body in _area.get_overlapping_bodies():
		if body is Car:
			return true
	return false
