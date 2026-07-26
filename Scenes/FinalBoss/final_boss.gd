class_name FinalBoss extends Node2D

signal died
signal car_hit

@onready var _body_sprite: AnimatedSprite2D = $Sprite2D
@onready var _dial: Sprite2D = $Dial
@onready var _dial_area: Area2D = $Dial/Area2D
@onready var _dial_collision_shape: CollisionShape2D = $Dial/Area2D/CollisionShape2D
@onready var _collision_shape: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _core: BossCore = $BossCore
@onready var _audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


func _ready() -> void:
    _core.killed.connect(_die)
    _core.hit_taken.connect(_flash)
    _dial_area.body_entered.connect(_on_dial_body_entered)
    _animation_player.animation_finished.connect(_on_animation_finished)


func _process(delta: float) -> void:
    if _core.is_dead():
        return
    _dial.rotation += deg_to_rad(Constants.final_boss_dial_speed_degrees) * delta


func is_dead() -> bool:
    return _core.is_dead()


func hit() -> bool:
    return _core.hit()


func get_radius() -> float:
    return (($StaticBody2D/CollisionShape2D as CollisionShape2D).shape as CapsuleShape2D).radius


func _flash() -> void:
    _body_sprite.self_modulate = Color(1.0, 1.0, 1.0, 0.3)
    _dial.self_modulate = Color(1.0, 1.0, 1.0, 0.3)
    var tween := create_tween()
    tween.tween_property(_body_sprite, "self_modulate", Color(1.0, 1.0, 1.0, 1.0), _core.invincibility_duration)
    tween.parallel().tween_property(_dial, "self_modulate", Color(1.0, 1.0, 1.0, 1.0), _core.invincibility_duration)


func _on_dial_body_entered(body: Node2D) -> void:
    if !(body as CollisionObject2D).get_collision_layer_value(CollisionLayers.CAR_BODY):
        return
    (body as Car).die()
    _audio_stream_player.play()
    car_hit.emit()


func _die() -> void:
    _collision_shape.set_deferred("disabled", true)
    _dial_collision_shape.set_deferred("disabled", true)
    _animation_player.play("die")
    MusicPlayer.stop_boss_music(Constants.boss_intro_music_fade_seconds)
    SfxPlayer.play_win_boss()


func _on_animation_finished(anim_name: StringName) -> void:
    if anim_name == "die":
        died.emit()
