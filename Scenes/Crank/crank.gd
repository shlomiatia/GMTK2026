class_name Crank extends Node2D

signal launched(power_ratio: float)

static var reset_crank_seconds := 1.0

@onready var _crank_sprite: Sprite2D = $CrankSprite
@onready var _progress_bar: TextureProgressBar = $ProgressBar
@onready var _audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var _virtual_mouse_icon: Sprite2D = $VirtualMouseIcon
@onready var _pivot_icon: Sprite2D = $PivotIcon

var _crank_degrees: float = 0.0
var _last_full_rotations: int = 0
var _cranking: bool = false
var _auto_cranking: bool = false
var _last_angle: float = NAN
var _using_mouse: bool = false
var _virtual_mouse_pos: Vector2 = Vector2.ZERO
var _crank_pivot: Vector2 = Vector2.ZERO

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    _progress_bar.min_value = 0.0
    _progress_bar.max_value = Constants.max_crank_degrees
    _progress_bar.value = 0.0

func _input(event: InputEvent) -> void:
    if !_cranking || !_using_mouse || Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
        return
    if !(event is InputEventMouseMotion):
        return
    var relative := (event as InputEventMouseMotion).relative
    _virtual_mouse_pos += get_viewport().get_canvas_transform().affine_inverse().basis_xform(relative)
    _virtual_mouse_icon.global_position = _virtual_mouse_pos


func _process(delta: float) -> void:
    if Input.is_action_just_pressed("crank"):
        _using_mouse = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
        if _using_mouse:
            _crank_pivot = _crank_sprite.get_global_mouse_position()
            _virtual_mouse_pos = _crank_pivot
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
            _virtual_mouse_icon.global_position = _virtual_mouse_pos
            _virtual_mouse_icon.visible = true
            _pivot_icon.global_position = _crank_pivot
            _pivot_icon.visible = true
        _cranking = true
        _last_angle = _get_crank_angle()
    elif Input.is_action_just_released("crank"):
        if _using_mouse:
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
            _virtual_mouse_icon.visible = false
            _pivot_icon.visible = false
        _cranking = false
        _try_launch()
    elif _cranking:
        var angle := _get_crank_angle()
        if is_nan(angle):
            _last_angle = NAN
        else:
            if !is_nan(_last_angle):
                _advance_crank(angle, _last_angle)
            _last_angle = angle

    if Input.is_action_just_pressed("auto_crank"):
        _auto_cranking = true
    elif Input.is_action_just_released("auto_crank"):
        _auto_cranking = false
        _try_launch()
    elif _auto_cranking:
        _add_crank_degrees(Constants.auto_crank_degrees_per_second * delta)


func set_enabled(value: bool) -> void:
    set_process(value)
    set_process_input(value)
    if !value:
        _cranking = false
        _auto_cranking = false


func _get_crank_angle() -> float:
    if _using_mouse:
        return (_virtual_mouse_pos - _crank_pivot).angle()
    var stick := Vector2(
        Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),
        Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
    )
    if stick.length() > 0.3:
        return stick.angle()
    return NAN


func _advance_crank(new_angle: float, prev_angle: float) -> void:
    var delta := wrapf(new_angle - prev_angle, -PI, PI)
    if delta <= 0.0:
        return
    _add_crank_degrees(rad_to_deg(delta))


func _add_crank_degrees(degrees: float) -> void:
    var to_add := minf(degrees, Constants.max_crank_degrees - _crank_degrees)
    if to_add <= 0.0:
        return
    _crank_degrees += to_add
    _crank_sprite.rotation_degrees = _crank_degrees
    _progress_bar.value = _crank_degrees
    var full := int(_crank_degrees / 360.0)
    if full > _last_full_rotations:
        _last_full_rotations = full
        _audio_stream_player.play()


func _try_launch() -> void:
    if _crank_degrees <= 0.0:
        return
    var power_ratio := _crank_degrees / Constants.max_crank_degrees
    _crank_degrees = 0.0
    _last_full_rotations = 0
    _progress_bar.value = 0.0
    var tween := create_tween()
    tween.tween_property(_crank_sprite, "rotation_degrees", 0.0, reset_crank_seconds).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    launched.emit(power_ratio)


func get_launch_speed() -> float:
    return _crank_degrees / Constants.max_crank_degrees * Constants.max_speed
