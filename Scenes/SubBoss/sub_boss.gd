class_name SubBoss extends CharacterBody2D

signal died

enum State {AIMING, CRANKING, LAUNCHED}

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _collision_shape: CollisionShape2D = $CollisionShape2D
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _aim_timer: Timer = $AimTimer
@onready var _core: BossCore = $BossCore

var _car: Car
var _state: State = State.AIMING
var _crank_elapsed: float = 0.0


func _ready() -> void:
    _car = get_tree().get_first_node_in_group("car") as Car
    _core.killed.connect(_die)
    _animation_player.animation_finished.connect(_on_animation_finished)
    _aim_timer.wait_time = Constants.sub_boss_aim_duration
    _aim_timer.timeout.connect(_on_aim_timer_timeout)
    _aim_timer.start()


func _physics_process(delta: float) -> void:
    if _core.is_dead() || !_car:
        return
    match _state:
        State.AIMING:
            _rotate_toward_car(delta)
        State.CRANKING:
            _advance_crank(delta)
        State.LAUNCHED:
            _advance_launch(delta)


func _rotate_toward_car(delta: float) -> void:
    var to_car := _car.global_position - global_position
    rotation = MathUtils.aim_toward(rotation, to_car, Constants.steer_speed, delta)


func _on_aim_timer_timeout() -> void:
    if _core.is_dead():
        return
    _state = State.CRANKING
    _crank_elapsed = 0.0


func _advance_crank(delta: float) -> void:
    _crank_elapsed += delta
    var t := clampf(_crank_elapsed / Constants.sub_boss_crank_duration, 0.0, 1.0)
    _sprite.self_modulate = Color(1.0, 1.0 - t, 1.0 - t)
    if t >= 1.0:
        _launch()


func _launch() -> void:
    _state = State.LAUNCHED
    velocity = Vector2.DOWN.rotated(rotation) * Constants.max_speed


func _advance_launch(delta: float) -> void:
    velocity = velocity.move_toward(Vector2.ZERO, Constants.friction * delta)
    _handle_collision(move_and_collide(velocity * delta))
    if _core.is_dead():
        return
    if velocity.length() < Constants.rest_velocity_threshold:
        _state = State.AIMING
        _sprite.self_modulate = Color(1.0, 1.0, 1.0)
        _aim_timer.start()


func _handle_collision(collision: KinematicCollision2D) -> void:
    if !collision:
        return
    var car := collision.get_collider() as Car
    if car && velocity.length() >= Constants.enemy_kill_speed:
        car.die()
    velocity = velocity.bounce(collision.get_normal())


func is_dead() -> bool:
    return _core.is_dead()


func hit() -> bool:
    return _core.hit()


func _die() -> void:
    _aim_timer.stop()
    velocity = Vector2.ZERO
    _collision_shape.set_deferred("disabled", true)
    _animation_player.play("die")


func _on_animation_finished(anim_name: StringName) -> void:
    if anim_name == "die":
        died.emit()
