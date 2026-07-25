@tool
class_name Pillar extends Node2D

@export var radius: float = 50.0:
	set(value):
		radius = value
		_update()

@onready var _collision_shape: CollisionShape2D = $StaticBody2D/CollisionShape2D


func _ready() -> void:
	_update()


func _update() -> void:
	if !is_node_ready():
		return
	(_collision_shape.shape as CircleShape2D).radius = radius
