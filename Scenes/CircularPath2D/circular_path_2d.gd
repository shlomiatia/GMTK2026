@tool
class_name CircularPath2D extends Path2D

const _CIRCLE_MAGIC := 0.552284749831

@export var radius: float = 100.0:
	set(value):
		radius = value
		_update()


func _ready() -> void:
	_update()


func _update() -> void:
	if !is_node_ready() || !curve:
		return
	curve.clear_points()
	var segment_count := 4
	for i in range(segment_count + 1):
		var angle := TAU * i / float(segment_count)
		var direction := Vector2(cos(angle), sin(angle))
		var tangent := Vector2(-sin(angle), cos(angle)) * radius * _CIRCLE_MAGIC
		curve.add_point(direction * radius, -tangent, tangent)
