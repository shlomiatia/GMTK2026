class_name Gear extends Node2D

signal collected

@onready var _area: Area2D = $Area2D
@onready var _collision_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var _animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
    _area.body_entered.connect(_on_body_entered)
    _animation_player.animation_finished.connect(_on_animation_finished)


func _on_body_entered(body: Node2D) -> void:
    if !(body is Car):
        return
    _collision_shape.set_deferred("disabled", true)
    _animation_player.play("die")
    collected.emit()


func _on_animation_finished(anim_name: StringName) -> void:
    if anim_name == "die":
        queue_free()
