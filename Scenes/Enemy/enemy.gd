class_name Enemy extends Node2D

signal died

@onready var _collision_shape: CollisionShape2D = $CharacterBody2D/CollisionShape2D
@onready var _animation_player: AnimationPlayer = $AnimationPlayer

var _path_follow: PathFollow2D
var _direction: float = 1.0
var _is_dead: bool = false


func _ready() -> void:
	_path_follow = get_parent() as PathFollow2D


func _physics_process(delta: float) -> void:
	if _is_dead || !_path_follow:
		return
	_path_follow.progress += Constants.enemy_speed * _direction * delta
	if _path_follow.progress_ratio >= 1.0:
		_direction = -1.0
	elif _path_follow.progress_ratio <= 0.0:
		_direction = 1.0


func is_dead() -> bool:
	return _is_dead


func die() -> void:
	if _is_dead:
		return
	_is_dead = true
	_collision_shape.set_deferred("disabled", true)
	_animation_player.play("die")
	died.emit()
