class_name Hazard extends Node2D

signal car_entered(car: Car)

@export var start_disabled: bool = false

@onready var _area: Area2D = $Area2D
@onready var _collision_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


func _ready() -> void:
	_area.body_entered.connect(_on_body_entered)
	_animation_player.animation_finished.connect(_on_animation_finished)
	if start_disabled:
		_spawn_in()


func _on_body_entered(body: Node2D) -> void:
	if !(body as CollisionObject2D).get_collision_layer_value(CollisionLayers.CAR_BODY):
		return
	_audio_stream_player.play()
	car_entered.emit(body as Car)


func get_radius() -> float:
	return (($Area2D/CollisionShape2D as CollisionShape2D).shape as CircleShape2D).radius


func despawn() -> void:
	remove_from_group("hazard")
	_collision_shape.set_deferred("disabled", true)
	_animation_player.play("fadeout")


func _spawn_in() -> void:
	_collision_shape.set_deferred("disabled", true)
	_animation_player.play("fadein")
	_animation_player.seek(0.0, true)


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fadein":
		_collision_shape.set_deferred("disabled", false)
		_animation_player.play("default")
	elif anim_name == "fadeout":
		queue_free()
