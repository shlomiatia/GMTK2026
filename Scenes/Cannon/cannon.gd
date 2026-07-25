class_name Cannon extends Node2D

signal died
signal fired

@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _collision_shape: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var _turret: Turret = $TurretController

var _is_dead: bool = false


func fire() -> void:
	_turret.fire()
	fired.emit()


func is_dead() -> bool:
	return _is_dead


func get_radius() -> float:
	return (($StaticBody2D/CollisionShape2D as CollisionShape2D).shape as CircleShape2D).radius


func die() -> void:
	if _is_dead:
		return
	_is_dead = true
	_turret.stop()
	_collision_shape.set_deferred("disabled", true)
	_animation_player.play("die")
	died.emit()
