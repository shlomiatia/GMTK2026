class_name CannonBoss extends Node2D

signal died

@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _collision_shape: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var _turret: Turret = $TurretController
@onready var _core: BossCore = $BossCore


func _ready() -> void:
    _core.killed.connect(_die)
    _animation_player.animation_finished.connect(_on_animation_finished)


func fire() -> void:
    _turret.fire()


func is_dead() -> bool:
    return _core.is_dead()


func hit() -> bool:
    return _core.hit()


func _die() -> void:
    _turret.stop()
    _collision_shape.set_deferred("disabled", true)
    _animation_player.play("die")


func _on_animation_finished(anim_name: StringName) -> void:
    if anim_name == "die":
        died.emit()
