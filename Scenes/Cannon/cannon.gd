class_name Cannon extends Node2D

@export var bullet_scene: PackedScene

@onready var _turret: Sprite2D = $Turret
@onready var _muzzle: Node2D = $Turret/Node2D
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _fire_timer: Timer = $FireTimer
@onready var _bullet_delay_timer: Timer = $BulletDelayTimer

var _car: Car
var _rotating: bool = true


func _ready() -> void:
	_car = get_tree().get_first_node_in_group("car") as Car
	_fire_timer.timeout.connect(_on_fire_timer_timeout)
	_bullet_delay_timer.timeout.connect(_on_bullet_delay_timer_timeout)
	_animation_player.animation_finished.connect(_on_animation_finished)


func _physics_process(delta: float) -> void:
	if !_rotating || !_car:
		return
	var to_target := _car.global_position - _turret.global_position
	if to_target.length() <= 0.0:
		return
	var target_rotation := to_target.angle() - PI / 2.0
	var max_delta := deg_to_rad(Constants.cannon_turret_speed_degrees) * delta
	_turret.rotation = rotate_toward(_turret.rotation, target_rotation, max_delta)


func _on_fire_timer_timeout() -> void:
	_rotating = false
	_animation_player.play("fire")
	_bullet_delay_timer.start()


func _on_bullet_delay_timer_timeout() -> void:
	var bullet := bullet_scene.instantiate() as Node2D
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = _muzzle.global_position
	bullet.rotation = _muzzle.global_rotation


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fire":
		_rotating = true
