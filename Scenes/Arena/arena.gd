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

@export var width: float = 0.0:
	set(value):
		width = value
		_update()

@export var offset_degrees: float = 0.0:
	set(value):
		offset_degrees = value
		_update()

@export var circum_degrees: float = 360.0:
	set(value):
		circum_degrees = value
		_update()

@onready var _collision_polygon: CollisionPolygon2D = $CollisionPolygon2D


func _ready() -> void:
	_update()


func _update() -> void:
	if !is_node_ready():
		return
	if width > 0:
		_collision_polygon.build_mode = CollisionPolygon2D.BUILD_SOLIDS
		_collision_polygon.polygon = _ring_points()
	else:
		_collision_polygon.build_mode = CollisionPolygon2D.BUILD_SEGMENTS
		_collision_polygon.polygon = _circle_points(radius)


func _circle_points(r: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in range(number_of_points):
		var t := float(i) / float(number_of_points - 1) if number_of_points > 1 else 0.0
		var angle := deg_to_rad(offset_degrees + circum_degrees * t)
		points.append(Vector2(cos(angle), sin(angle)) * r)
	return points


func _ring_points() -> PackedVector2Array:
	var points := _circle_points(radius - width / 2.0)
	var outer_points := _circle_points(radius + width / 2.0)
	outer_points.reverse()
	points.append_array(outer_points)
	return points
