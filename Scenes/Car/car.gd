class_name Car extends CharacterBody2D

const MAX_CRANK_DEGREES := 5.0 * 360.0
const MAX_SPEED := 1180.0
const FRICTION := 300.0
const RESET_CRANK_SECONDS := 1.0

@onready var _crank_sprite: Sprite2D = $Crank
@onready var _audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var _crank_degrees: float = 0.0
var _last_full_rotations: int = 0
var _is_launched: bool = false

var _mouse_cranking: bool = false
var _mouse_last_angle: float = 0.0

var _pad_cranking: bool = false
var _pad_last_angle: float = 0.0
var _pad_trigger_held: bool = false


func _process(_delta: float) -> void:
    if _is_launched:
        return
    _handle_mouse_input()
    _handle_gamepad_input()


func _physics_process(delta: float) -> void:
    if !_is_launched:
        return
    velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
    move_and_slide()
    if velocity == Vector2.ZERO:
        _is_launched = false
        _crank_degrees = 0.0
        _last_full_rotations = 0


func _handle_mouse_input() -> void:
    if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        var angle := (get_global_mouse_position() - global_position).angle()
        if !_mouse_cranking:
            _mouse_cranking = true
            _mouse_last_angle = angle
        else:
            _advance_crank(angle, _mouse_last_angle)
            _mouse_last_angle = angle
    elif _mouse_cranking:
        _mouse_cranking = false
        _launch()


func _handle_gamepad_input() -> void:
    var trigger := Input.get_joy_axis(0, JOY_AXIS_TRIGGER_RIGHT)
    var trigger_held := trigger > 0.5
    var stick := Vector2(
        Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),
        Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
    )

    if trigger_held:
        if stick.length() > 0.3:
            var angle := stick.angle()
            if !_pad_cranking:
                _pad_cranking = true
                _pad_last_angle = angle
            else:
                _advance_crank(angle, _pad_last_angle)
                _pad_last_angle = angle
        else:
            _pad_cranking = false
    else:
        _pad_cranking = false
        if _pad_trigger_held:
            _launch()
    _pad_trigger_held = trigger_held


func _advance_crank(new_angle: float, prev_angle: float) -> void:
    var delta := wrapf(new_angle - prev_angle, -PI, PI)
    if delta <= 0.0:
        return
    var to_add := minf(rad_to_deg(delta), MAX_CRANK_DEGREES - _crank_degrees)
    if to_add <= 0.0:
        return
    _crank_degrees += to_add
    _crank_sprite.rotation_degrees = _crank_degrees
    var full := int(_crank_degrees / 360.0)
    if full > _last_full_rotations:
        _last_full_rotations = full
        _audio_stream_player.play()


func _launch() -> void:
    if _crank_degrees <= 0.0 || _is_launched:
        return
    _is_launched = true
    var tween := create_tween()
    tween.tween_property(_crank_sprite, "rotation_degrees", 0.0, RESET_CRANK_SECONDS).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    velocity = - transform.y * (_crank_degrees / MAX_CRANK_DEGREES) * MAX_SPEED
