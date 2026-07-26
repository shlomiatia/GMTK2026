class_name CannonBoss extends Node2D

signal died
signal fired

@onready var _base_sprite: Sprite2D = $Base
@onready var _turret_sprite: Sprite2D = $Turret
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _collision_shape: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var _turret: Turret = $TurretController
@onready var _core: BossCore = $BossCore
@onready var _audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var _shuddering: bool = false
var _shudder_base_position: Vector2


func _ready() -> void:
    _core.killed.connect(_die)
    _core.hit_taken.connect(_flash)
    _animation_player.animation_finished.connect(_on_animation_finished)


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
    fired.emit()


func is_dead() -> bool:
    return _core.is_dead()


func hit() -> bool:
    return _core.hit()


func _flash() -> void:
    _base_sprite.self_modulate = Color(1.0, 1.0, 1.0, 0.3)
    _turret_sprite.self_modulate = Color(1.0, 1.0, 1.0, 0.3)
    var tween := create_tween()
    tween.set_parallel(true)
    tween.tween_property(_base_sprite, "self_modulate", Color(1.0, 1.0, 1.0, 1.0), _core.invincibility_duration)
    tween.tween_property(_turret_sprite, "self_modulate", Color(1.0, 1.0, 1.0, 1.0), _core.invincibility_duration)


func get_radius() -> float:
    return (($StaticBody2D/CollisionShape2D as CollisionShape2D).shape as CircleShape2D).radius


func _die() -> void:
    stop_shudder()
    _turret.stop()
    _collision_shape.set_deferred("disabled", true)
    _animation_player.play("die")
    SfxPlayer.play_win_boss()


func _on_animation_finished(anim_name: StringName) -> void:
    if anim_name == "die":
        died.emit()
