class_name MinionBoss extends Node2D

signal died

@onready var _collision_shape: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _invincibility_timer: Timer = $InvincibilityTimer

var _hits_taken: int = 0
var _is_dead: bool = false
var _is_invincible: bool = false


func _ready() -> void:
	_invincibility_timer.wait_time = Constants.minion_boss_invincibility_duration
	_invincibility_timer.timeout.connect(_on_invincibility_timer_timeout)
	_animation_player.animation_finished.connect(_on_animation_finished)


func is_dead() -> bool:
	return _is_dead


func hit() -> bool:
	if _is_dead || _is_invincible:
		return false
	_hits_taken += 1
	if _hits_taken >= Constants.minion_boss_hits_to_kill:
		die()
		return true
	_is_invincible = true
	_invincibility_timer.start()
	return true


func _on_invincibility_timer_timeout() -> void:
	_is_invincible = false


func die() -> void:
	if _is_dead:
		return
	_is_dead = true
	_collision_shape.set_deferred("disabled", true)
	_animation_player.play("die")


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "die":
		died.emit()
