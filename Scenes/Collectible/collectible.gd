class_name Collectible extends Node2D

signal collected

@onready var _area: Area2D = $Area2D
@onready var _collision_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


func _ready() -> void:
    _area.area_entered.connect(_on_area_entered)
    _animation_player.animation_finished.connect(_on_animation_finished)


func _on_area_entered(area: Area2D) -> void:
    if !area.get_collision_layer_value(CollisionLayers.CAR_SENSOR):
        return
    _collision_shape.set_deferred("disabled", true)
    _animation_player.play("die")
    _audio_stream_player.play()
    collected.emit()


func get_radius() -> float:
    return (($Area2D/CollisionShape2D as CollisionShape2D).shape as CircleShape2D).radius


func _on_animation_finished(anim_name: StringName) -> void:
    if anim_name != "die":
        return
    if _audio_stream_player.playing:
        _audio_stream_player.finished.connect(queue_free)
    else:
        queue_free()
