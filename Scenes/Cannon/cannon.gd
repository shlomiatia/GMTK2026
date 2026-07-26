class_name Cannon extends Node2D

signal died
signal fired

@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _collision_shape: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var _turret: Turret = $TurretController
@onready var _audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var _smoke: SmokeParticleEmitter = $Turret/Node2D/SmokeParticleEmitter

var _is_dead: bool = false
var _shuddering: bool = false
var _shudder_base_position: Vector2


func _process(_delta: float) -> void:
	if _shuddering:
		ShudderUtils.update(self, _shudder_base_position, Constants.shudder_intensity)


func start_shudder() -> void:
	_shudder_base_position = position
	_shuddering = true


func stop_shudder() -> void:
	if _shuddering:
		position = _shudder_base_position
	_shuddering = false


func fire() -> void:
	stop_shudder()
	_turret.fire()
	_audio_stream_player.play()
	_smoke.restart()
	_smoke.emitting = true
	fired.emit()


func is_dead() -> bool:
	return _is_dead


func get_radius() -> float:
	return (($StaticBody2D/CollisionShape2D as CollisionShape2D).shape as CircleShape2D).radius


func die() -> void:
	if _is_dead:
		return
	_is_dead = true
	stop_shudder()
	_turret.stop()
	_collision_shape.set_deferred("disabled", true)
	_animation_player.play("die")
	died.emit()
