class_name MinionBoss extends Node2D

signal died

@export var enemy_scene: PackedScene

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
	for enemy in get_tree().get_nodes_in_group("enemy"):
		_connect_enemy(enemy as Enemy)


func _connect_enemy(enemy: Enemy) -> void:
	if !enemy:
		return
	enemy.died.connect(_on_enemy_died.bind(enemy))


func _on_enemy_died(enemy: Enemy) -> void:
	var path := enemy.get_path2d()
	if !path:
		return
	var loop := enemy.loop
	var key := enemy.key
	await get_tree().create_timer(Constants.minion_respawn_delay).timeout
	_spawn_enemy(path, loop, key)


func _spawn_enemy(path: Path2D, loop: bool, key: bool) -> void:
	var enemy := enemy_scene.instantiate() as Enemy
	enemy.loop = loop
	enemy.key = key
	enemy.start_disabled = true
	path.add_child(enemy)
	_connect_enemy(enemy)


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
