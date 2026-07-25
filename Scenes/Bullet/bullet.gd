class_name Bullet extends Node2D

@onready var _area: Area2D = $Area2D


func _ready() -> void:
	_area.body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	global_position += Vector2.DOWN.rotated(rotation) * Constants.bullet_speed * delta


func _on_body_entered(body: Node2D) -> void:
	var car := body as Car
	if car:
		car.die()
	queue_free()
