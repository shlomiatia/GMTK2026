class_name Enemy extends CharacterBody2D

signal died

const ARRIVAL_DISTANCE := 4.0
const KEY_OFFSET := Vector2(0.0, -80.0)

@export var loop: bool = true
@export var key: bool = false

@onready var _collision_shape: CollisionShape2D = $CollisionShape2D
@onready var _collision_shape2: CollisionShape2D = $CollisionShape2D2
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _key_sprite: Sprite2D = $Key

var _path: Path2D
var _path_follow: PathFollow2D
var _direction: int = 1
var _is_dead: bool = false


func _ready() -> void:
	_key_sprite.visible = key
	_path = get_parent() as Path2D
	if !_path:
		return
	_path_follow = PathFollow2D.new()
	_path_follow.loop = loop
	_path.add_child.call_deferred(_path_follow)
	_snap_to_path_follow.call_deferred()


func _snap_to_path_follow() -> void:
	global_position = _path_follow.global_position
	_set_initial_rotation()


func _set_initial_rotation() -> void:
	if _path.curve.point_count < 2:
		return
	var p0 := _path.to_global(_path.curve.get_point_position(0))
	var p1 := _path.to_global(_path.curve.get_point_position(1))
	var direction := p1 - p0
	if direction.length() > 0.0:
		rotation = direction.angle() - PI / 2.0


func _process(_delta: float) -> void:
	if !key:
		return
	_key_sprite.global_position = global_position + KEY_OFFSET


func _physics_process(delta: float) -> void:
	if _is_dead || !_path_follow:
		return
	var length := _path.curve.get_baked_length()
	if length <= 0.0:
		return
	var ratio := _path_follow.progress_ratio + Constants.enemy_speed * delta * _direction / length
	if !loop:
		if ratio >= 1.0:
			ratio = 1.0
			_direction = -1
		elif ratio <= 0.0:
			ratio = 0.0
			_direction = 1
	_path_follow.progress_ratio = ratio
	var to_target := _path_follow.global_position - global_position
	var distance := to_target.length()
	if distance > 0.0:
		var target_rotation := to_target.angle() - PI / 2.0
		var max_delta := deg_to_rad(Constants.enemy_turn_speed_degrees) * delta
		rotation = rotate_toward(rotation, target_rotation, max_delta)
	if distance <= ARRIVAL_DISTANCE:
		return
	velocity = to_target.normalized() * Constants.enemy_speed
	move_and_collide(velocity * delta)


func is_dead() -> bool:
	return _is_dead


func die() -> void:
	prints("wtf")
	if _is_dead:
		return
	_is_dead = true
	velocity = Vector2.ZERO
	_collision_shape.set_deferred("disabled", true)
	_collision_shape2.set_deferred("disabled", true)
	_animation_player.play("die")
	if _path_follow:
		_path_follow.queue_free()
		_path_follow = null
	died.emit()
