class_name Bullet extends Node2D

signal car_hit(car: Car)

const _wall_collision_sfx := [
	preload("res://Audio/SFX V1/Wall collision-001.wav"),
	preload("res://Audio/SFX V1/Wall collision-002.wav"),
]

@onready var _area: Area2D = $Area2D
@onready var _sprite: Sprite2D = $Sprite2D
@onready var _audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var _wall_sfx_index: int = 0


func _ready() -> void:
	_area.body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	global_position += Vector2.DOWN.rotated(rotation) * Constants.bullet_speed * delta


func _on_body_entered(body: Node2D) -> void:
	var car := body as Car
	if car:
		car.die()
		car_hit.emit(car)
	else:
		_audio_stream_player.stream = _wall_collision_sfx[_wall_sfx_index]
		_wall_sfx_index = 1 - _wall_sfx_index
	_sprite.visible = false
	_area.set_deferred("monitoring", false)
	set_physics_process(false)
	_audio_stream_player.finished.connect(queue_free)
	_audio_stream_player.play()
