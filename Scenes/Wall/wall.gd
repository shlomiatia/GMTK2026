@tool
class_name Wall extends ColorRect

@onready var _static_body: StaticBody2D = $StaticBody2D
@onready var _collision_shape: CollisionShape2D = $StaticBody2D/CollisionShape2D


func _ready() -> void:
	resized.connect(_update_collision)
	_update_collision()


func _update_collision() -> void:
	pivot_offset = size / 2.0
	_static_body.position = size / 2.0
	(_collision_shape.shape as RectangleShape2D).size = size
