class_name Crank extends Node2D

signal launched(power_ratio: float)
signal crank_pressed
signal crank_released(degrees: float)
signal cycle_completed

static var reset_crank_seconds := 1.0
static var min_move_pixels := 3.0

const _winder_click_sfx := preload("res://Audio/SFX V1/Winder Click.wav")
const _wind_sfx := [
	preload("res://Audio/SFX V1/Wind 1.wav"),
	preload("res://Audio/SFX V1/Wind 2.wav"),
	preload("res://Audio/SFX V1/Wind 3.wav"),
]
const _launch_sfx := [
	preload("res://Audio/SFX V1/Launch 0 Winds.wav"),
	preload("res://Audio/SFX V1/Launch 1 Winds.wav"),
	preload("res://Audio/SFX V1/Launch 2 Winds.wav"),
	preload("res://Audio/SFX V1/Launch 3 Winds.wav"),
]

@onready var _crank_sprite: Sprite2D = $CrankSprite
@onready var _progress_bar: TextureProgressBar = $ProgressBar
@onready var _audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var _virtual_cursor: VirtualCursor = $VirtualCursor

var _crank_degrees: float = 0.0
var _last_full_rotations: int = 0
var _cranking: bool = false
var _last_angle: float = NAN
var _last_move_angle: float = NAN
var _using_mouse: bool = false

func _ready() -> void:
    _virtual_cursor.moved.connect(_on_virtual_cursor_moved)
    _progress_bar.min_value = 0.0
    _progress_bar.max_value = Constants.max_crank_degrees
    _progress_bar.value = 0.0

func _on_virtual_cursor_moved(relative: Vector2) -> void:
    if !can_process():
        return
    if !_cranking || !_using_mouse:
        return
    if relative.length() < min_move_pixels:
        return
    var move_angle := relative.angle()
    if !is_nan(_last_move_angle):
        _advance_crank(move_angle, _last_move_angle)
    _last_move_angle = move_angle


func _process(delta: float) -> void:
    if GameState.auto_crank_enabled:
        if Input.is_action_just_pressed("crank"):
            _cranking = true
            _audio_stream_player.stream = _winder_click_sfx
            _audio_stream_player.play()
            crank_pressed.emit()
        elif Input.is_action_just_released("crank"):
            _cranking = false
            var degrees_before_launch := _crank_degrees
            _try_launch()
            crank_released.emit(degrees_before_launch)
        elif _cranking:
            _add_crank_degrees(Constants.auto_crank_degrees_per_second * delta)
        return

    if Input.is_action_just_pressed("crank"):
        _using_mouse = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
        _last_move_angle = NAN
        if !_using_mouse:
            _last_angle = _get_crank_angle()
        _cranking = true
        _audio_stream_player.stream = _winder_click_sfx
        _audio_stream_player.play()
        crank_pressed.emit()
    elif Input.is_action_just_released("crank"):
        _cranking = false
        var degrees_before_launch := _crank_degrees
        _try_launch()
        crank_released.emit(degrees_before_launch)
    elif _cranking && !_using_mouse:
        var angle := _get_crank_angle()
        if is_nan(angle):
            _last_angle = NAN
        else:
            if !is_nan(_last_angle):
                _advance_crank(angle, _last_angle)
            _last_angle = angle


func set_enabled(value: bool) -> void:
    set_process(value)
    if !value:
        _cranking = false


func _get_crank_angle() -> float:
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
        _audio_stream_player.stream = _wind_sfx[mini(_last_full_rotations, 3) - 1]
        _audio_stream_player.play()
        cycle_completed.emit()


func _try_launch() -> void:
    _audio_stream_player.stream = _launch_sfx[mini(_last_full_rotations, 3)]
    _audio_stream_player.play()
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


func get_pointer_world_position() -> Vector2:
    return _virtual_cursor.global_position
