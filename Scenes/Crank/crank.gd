class_name Crank extends Node2D

signal launched(power_ratio: float)

@onready var _car: Node2D = get_parent()
@onready var _crank_sprite: Sprite2D = $CrankSprite
@onready var _crank_area_shape: CollisionShape2D = $CrankSprite/Area2D/CollisionShape2D
@onready var _progress_bar: TextureProgressBar = $ProgressBar
@onready var _audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var _virtual_mouse_icon: Sprite2D = $VirtualMouseIcon

var _crank_degrees: float = 0.0
var _last_full_rotations: int = 0
var _cranking: bool = false
var _last_angle: float = NAN
var _using_mouse: bool = false
var _virtual_mouse_pos: Vector2 = Vector2.ZERO

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


func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("crank"):
        var mouse_pressed := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
        if mouse_pressed && !_is_mouse_over_crank_area():
            return
        _using_mouse = mouse_pressed
        if _using_mouse:
            _virtual_mouse_pos = _crank_sprite.get_global_mouse_position()
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
            _virtual_mouse_icon.global_position = _virtual_mouse_pos
            _virtual_mouse_icon.visible = true
        _cranking = true
        _last_angle = _get_crank_angle()
    elif Input.is_action_just_released("crank"):
        if _using_mouse:
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
            _virtual_mouse_icon.visible = false
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


func set_enabled(value: bool) -> void:
    set_process(value)
    set_process_input(value)


func _is_mouse_over_crank_area() -> bool:
    var half := (_crank_area_shape.shape as RectangleShape2D).size / 2.0
    var local := _crank_area_shape.to_local(_crank_area_shape.get_global_mouse_position())
    return absf(local.x) <= half.x && absf(local.y) <= half.y


func _get_crank_angle() -> float:
    if _using_mouse:
        return (_virtual_mouse_pos - _car.global_position).angle()
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
    var to_add := minf(rad_to_deg(delta), Constants.max_crank_degrees - _crank_degrees)
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
    tween.tween_property(_crank_sprite, "rotation_degrees", 0.0, Constants.reset_crank_seconds).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    launched.emit(power_ratio)
