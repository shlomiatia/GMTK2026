class_name HazardBoss extends Node2D

signal died

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _collision_shape: CollisionPolygon2D = $StaticBody2D/CollisionPolygon2D
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _core: BossCore = $BossCore

var _boss_radius: float = -1.0


func _ready() -> void:
    _core.killed.connect(_die)
    _core.hit_taken.connect(_flash)
    _animation_player.animation_finished.connect(_on_animation_finished)


func is_dead() -> bool:
    return _core.is_dead()


func hit() -> bool:
    return _core.hit()


func _flash() -> void:
    _sprite.self_modulate = Color(1.0, 1.0, 1.0, 0.3)
    var tween := create_tween()
    tween.tween_property(_sprite, "self_modulate", Color(1.0, 1.0, 1.0, 1.0), _core.invincibility_duration)


func get_radius() -> float:
    if _boss_radius < 0.0:
        var collision_polygon := get_node("StaticBody2D/CollisionPolygon2D") as CollisionPolygon2D
        _boss_radius = MathUtils.polygon_bounding_radius(collision_polygon.polygon)
    return _boss_radius


func _die() -> void:
    _collision_shape.set_deferred("disabled", true)
    _animation_player.play("die")
    SfxPlayer.play_win_boss()


func _on_animation_finished(anim_name: StringName) -> void:
    if anim_name == "die":
        died.emit()
