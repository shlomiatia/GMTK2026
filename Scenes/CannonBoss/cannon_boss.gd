class_name CannonBoss extends Node2D

signal died

@export var bullet_scene: PackedScene

@onready var _turret: Sprite2D = $Turret
@onready var _muzzle: Node2D = $Turret/Node2D
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _fire_timer: Timer = $FireTimer
@onready var _collision_shape: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var _invincibility_timer: Timer = $InvincibilityTimer

var _car: Car
var _rotating: bool = true
var _hits_taken: int = 0
var _is_dead: bool = false
var _is_invincible: bool = false


func _ready() -> void:
    prints("hi")
    _car = get_tree().get_first_node_in_group("car") as Car
    _fire_timer.timeout.connect(_on_fire_timer_timeout)
    _animation_player.animation_finished.connect(_on_animation_finished)
    _invincibility_timer.wait_time = Constants.cannon_boss_invincibility_duration
    _invincibility_timer.timeout.connect(_on_invincibility_timer_timeout)


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
    if _is_dead:
        return
    _rotating = false
    _animation_player.play("fire")


func fire() -> void:
    var bullet := bullet_scene.instantiate() as Node2D
    get_tree().current_scene.add_child(bullet)
    bullet.global_position = _muzzle.global_position
    bullet.rotation = _muzzle.global_rotation


func is_dead() -> bool:
    return _is_dead


func hit() -> bool:
    if _is_dead || _is_invincible:
        return false
    _hits_taken += 1
    if _hits_taken >= Constants.cannon_boss_hits_to_kill:
        die()
        return true
    _is_invincible = true
    _invincibility_timer.start()
    return true


func _on_invincibility_timer_timeout() -> void:
    _is_invincible = false


func die() -> void:
    if _is_dead:
        return
    _is_dead = true
    _rotating = false
    _fire_timer.stop()
    _collision_shape.set_deferred("disabled", true)
    _animation_player.play("die")


func _on_animation_finished(anim_name: StringName) -> void:
    if anim_name == "fire" && !_is_dead:
        _rotating = true
    if anim_name == "die":
        died.emit()
