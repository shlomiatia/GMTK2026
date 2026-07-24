class_name Hazard extends Node2D

signal car_entered(car: Car)

@onready var _area: Area2D = $Area2D


func _ready() -> void:
	_area.body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if !(body as CollisionObject2D).get_collision_layer_value(CollisionLayers.CAR_BODY):
		return
	car_entered.emit(body as Car)
