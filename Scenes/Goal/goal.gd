class_name Goal extends Node2D

@onready var _area: Area2D = $Area2D


func has_car() -> bool:
	for area in _area.get_overlapping_areas():
		if area.get_collision_layer_value(CollisionLayers.CAR_SENSOR):
			return true
	return false
