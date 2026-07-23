class_name Enemy extends CharacterBody2D

signal died

const WAYPOINT_ARRIVAL_DISTANCE := 4.0

@onready var _collision_shape: CollisionShape2D = $CollisionShape2D
@onready var _animation_player: AnimationPlayer = $AnimationPlayer

var _path: Path2D
var _waypoint_index: int = 0
var _direction: int = 1
var _is_dead: bool = false


func _ready() -> void:
	_path = get_parent() as Path2D
	if _path && _path.curve.point_count > 0:
		global_position = _path.global_transform * _path.curve.get_point_position(_waypoint_index)


func _physics_process(delta: float) -> void:
	if _is_dead || !_path || _path.curve.point_count < 2:
		return
	var target := _path.global_transform * _path.curve.get_point_position(_waypoint_index)
	var to_target := target - global_position
	if to_target.length() <= WAYPOINT_ARRIVAL_DISTANCE:
		_advance_waypoint()
		return
	velocity = to_target.normalized() * Constants.enemy_speed
	move_and_collide(velocity * delta)


func _advance_waypoint() -> void:
	var last_index := _path.curve.point_count - 1
	if _waypoint_index >= last_index:
		_direction = -1
	elif _waypoint_index <= 0:
		_direction = 1
	_waypoint_index += _direction


func is_dead() -> bool:
	return _is_dead


func die() -> void:
	if _is_dead:
		return
	_is_dead = true
	velocity = Vector2.ZERO
	_collision_shape.set_deferred("disabled", true)
	_animation_player.play("die")
	died.emit()
