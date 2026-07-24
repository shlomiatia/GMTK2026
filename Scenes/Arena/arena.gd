@tool
class_name Arena extends StaticBody2D

@export var radius: float = 10.0:
	set(value):
		radius = value
		_update()

@export var number_of_points: int = 24:
	set(value):
		number_of_points = value
		_update()

@onready var _collision_polygon: CollisionPolygon2D = $CollisionPolygon2D


func _ready() -> void:
	_update()


func _update() -> void:
	if !is_node_ready():
		return
	var points := PackedVector2Array()
	for i in range(number_of_points):
		var angle := TAU * i / float(number_of_points)
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	_collision_polygon.polygon = points
