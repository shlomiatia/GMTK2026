class_name MinionBoss extends Node2D

signal died

@export var enemy_scene: PackedScene

@onready var _sprite: AnimatedSprite2D = $Sprite2D
@onready var _collision_shape: CollisionPolygon2D = $StaticBody2D/CollisionPolygon2D
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _core: BossCore = $BossCore


func _ready() -> void:
    _core.killed.connect(_die)
    _core.hit_taken.connect(_flash)
    _animation_player.animation_finished.connect(_on_animation_finished)
    _sprite.animation_finished.connect(_on_animated_sprite_2d_animation_finished)
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
    if _core.is_dead():
        return
    _spawn_enemy(path, loop, key)


func _spawn_enemy(path: Path2D, loop: bool, key: bool) -> void:
    _sprite.play("attack")
    var enemy := enemy_scene.instantiate() as Enemy
    enemy.loop = loop
    enemy.key = key
    enemy.start_disabled = true
    path.add_child(enemy)
    _connect_enemy(enemy)


func is_dead() -> bool:
    return _core.is_dead()


func hit() -> bool:
    return _core.hit()


func _flash() -> void:
    _sprite.self_modulate = Color(1.0, 1.0, 1.0, 0.3)
    var tween := create_tween()
    tween.tween_property(_sprite, "self_modulate", Color(1.0, 1.0, 1.0, 1.0), _core.invincibility_duration)


func _die() -> void:
    _collision_shape.set_deferred("disabled", true)
    _animation_player.play("die")
    SfxPlayer.play_win_boss()


func _on_animation_finished(anim_name: StringName) -> void:
    if anim_name == "die":
        died.emit()

func _on_animated_sprite_2d_animation_finished(e) -> void:
    if _sprite.animation == "attack":
        _sprite.play("idle")
