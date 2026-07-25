@tool
class_name CircularPath2D extends Path2D

const _CIRCLE_MAGIC := 0.552284749831

@export var radius: float = 100.0:
	set(value):
		radius = value
		_update()

@export var counter_clockwise: bool = false:
	set(value):
		counter_clockwise = value
		_update()


func _ready() -> void:
	_update()


func _update() -> void:
	if !is_node_ready() || !curve:
		return
	curve.clear_points()
	var segment_count := 4
	var direction_sign := -1.0 if counter_clockwise else 1.0
	for i in range(segment_count + 1):
		var angle := TAU * i / float(segment_count) * direction_sign
		var direction := Vector2(cos(angle), sin(angle))
		var tangent := Vector2(-sin(angle), cos(angle)) * radius * _CIRCLE_MAGIC * direction_sign
		curve.add_point(direction * radius, -tangent, tangent)
