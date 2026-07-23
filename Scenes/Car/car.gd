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

var _cranking: bool = false
var _last_angle: float = NAN
var _using_mouse: bool = false


func _process(_delta: float) -> void:
	if _is_launched:
		return
	if Input.is_action_just_pressed("crank"):
		_using_mouse = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
		_cranking = true
		_last_angle = _get_crank_angle()
	elif Input.is_action_just_released("crank"):
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


func _get_crank_angle() -> float:
	if _using_mouse:
		return (get_global_mouse_position() - global_position).angle()
	var stick := Vector2(
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	)
	if stick.length() > 0.3:
		return stick.angle()
	return NAN


func _physics_process(delta: float) -> void:
	if !_is_launched:
		return
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	move_and_slide()
	if velocity == Vector2.ZERO:
		_is_launched = false
		_crank_degrees = 0.0
		_last_full_rotations = 0


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
