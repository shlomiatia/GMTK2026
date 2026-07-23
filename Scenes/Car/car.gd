class_name Car extends CharacterBody2D

signal launched
signal rested
signal died
signal enemy_killed(enemy: Enemy)

@onready var _crank_sprite: Sprite2D = $Car/Crank
@onready var _crank_area_shape: CollisionShape2D = $Car/Crank/Area2D/CollisionShape2D
@onready var _audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var _collision_shape: CollisionShape2D = $CollisionShape2D
@onready var _animation_player: AnimationPlayer = $AnimationPlayer

var _crank_degrees: float = 0.0
var _last_full_rotations: int = 0
var _is_launched: bool = false
var _is_dead: bool = false

var _cranking: bool = false
var _last_angle: float = NAN
var _using_mouse: bool = false
var _virtual_mouse_pos: Vector2 = Vector2.ZERO

var _angular_velocity: float = 0.0


func _ready() -> void:
    _animation_player.animation_finished.connect(_on_animation_finished)


func _input(event: InputEvent) -> void:
    if !_cranking || !_using_mouse || Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
        return
    if !(event is InputEventMouseMotion):
        return
    var relative := (event as InputEventMouseMotion).relative
    _virtual_mouse_pos += get_viewport().get_canvas_transform().affine_inverse().basis_xform(relative)


func _process(_delta: float) -> void:
    if _is_dead || _is_launched:
        return
    if Input.is_action_just_pressed("crank"):
        var mouse_pressed := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
        if mouse_pressed && !_is_mouse_over_crank_area():
            return
        _using_mouse = mouse_pressed
        if _using_mouse:
            _virtual_mouse_pos = get_global_mouse_position()
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
        _cranking = true
        _last_angle = _get_crank_angle()
    elif Input.is_action_just_released("crank"):
        if _using_mouse:
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
        _cranking = false
        _launch()
    elif _cranking:
        var angle := _get_crank_angle()
        if is_nan(angle):
            _last_angle = NAN
        else:
            if !is_nan(_last_angle):
                _advance_crank(angle, _last_angle)
            _last_angle = angle


func _is_mouse_over_crank_area() -> bool:
    var half := (_crank_area_shape.shape as RectangleShape2D).size / 2.0
    var local := _crank_area_shape.to_local(get_global_mouse_position())
    return absf(local.x) <= half.x && absf(local.y) <= half.y


func _get_crank_angle() -> float:
    if _using_mouse:
        return (_virtual_mouse_pos - global_position).angle()
    var stick := Vector2(
        Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),
        Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
    )
    if stick.length() > 0.3:
        return stick.angle()
    return NAN


func _physics_process(delta: float) -> void:
    if _is_dead || !_is_launched:
        return
    var dir := Input.get_axis("left", "right")
    _angular_velocity = deg_to_rad(Constants.steer_speed) * dir
    var steer_angle := _apply_angular_velocity(delta)
    if steer_angle != 0.0:
        velocity = velocity.rotated(steer_angle)
    velocity = velocity.move_toward(Vector2.ZERO, Constants.friction * delta)
    var collision = move_and_collide(velocity * delta)
    if collision:
        var enemy := collision.get_collider() as Enemy
        if enemy && velocity.length() >= Constants.enemy_kill_speed:
            enemy.die()
            enemy_killed.emit(enemy)
        velocity = velocity.bounce(collision.get_normal())

    if velocity == Vector2.ZERO:
        _is_launched = false
        _crank_degrees = 0.0
        _last_full_rotations = 0
        _angular_velocity = 0.0
        rested.emit()


func _apply_angular_velocity(delta: float) -> float:
    var angle_delta := _angular_velocity * delta
    if angle_delta == 0.0:
        return 0.0
    var target_transform := Transform2D(rotation + angle_delta, global_position)
    if test_move(target_transform, Vector2.ZERO, null, 0.08, true):
        _angular_velocity = 0.0
        return 0.0
    rotation += angle_delta
    return angle_delta


func _advance_crank(new_angle: float, prev_angle: float) -> void:
    var delta := wrapf(new_angle - prev_angle, -PI, PI)
    if delta <= 0.0:
        return
    var to_add := minf(rad_to_deg(delta), Constants.max_crank_degrees - _crank_degrees)
    if to_add <= 0.0:
        return
    _crank_degrees += to_add
    _crank_sprite.rotation_degrees = _crank_degrees
    var full := int(_crank_degrees / 360.0)
    if full > _last_full_rotations:
        _last_full_rotations = full
        _audio_stream_player.play()


func get_bounding_radius() -> float:
    return (_collision_shape.shape as CapsuleShape2D).height / 2.0


func die() -> void:
    if _is_dead:
        return
    _is_dead = true
    _is_launched = false
    velocity = Vector2.ZERO
    _animation_player.play("die")


func _on_animation_finished(anim_name: StringName) -> void:
    if anim_name == "die":
        died.emit()


func _launch() -> void:
    if _crank_degrees <= 0.0 || _is_launched:
        return
    _is_launched = true
    launched.emit()
    var tween := create_tween()
    tween.tween_property(_crank_sprite, "rotation_degrees", 0.0, Constants.reset_crank_seconds).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    velocity = - transform.y * (_crank_degrees / Constants.max_crank_degrees) * Constants.max_speed
