class_name Car extends CharacterBody2D

@onready var _crank_sprite: Sprite2D = $Crank
@onready var _crank_area_shape: CollisionShape2D = $Crank/Area2D/CollisionShape2D
@onready var _audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var _crank_degrees: float = 0.0
var _last_full_rotations: int = 0
var _is_launched: bool = false

var _cranking: bool = false
var _last_angle: float = NAN
var _using_mouse: bool = false
var _virtual_mouse_pos: Vector2 = Vector2.ZERO


func _input(event: InputEvent) -> void:
	if !_cranking || !_using_mouse || Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	if !(event is InputEventMouseMotion):
		return
	var relative := (event as InputEventMouseMotion).relative
	_virtual_mouse_pos += get_viewport().get_canvas_transform().affine_inverse().basis_xform(relative)


func _process(_delta: float) -> void:
	if _is_launched:
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
	if !_is_launched:
		return
	velocity = velocity.move_toward(Vector2.ZERO, Constants.friction * delta)
	move_and_slide()
	if velocity == Vector2.ZERO:
		_is_launched = false
		_crank_degrees = 0.0
		_last_full_rotations = 0


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


func _launch() -> void:
	if _crank_degrees <= 0.0 || _is_launched:
		return
	_is_launched = true
	var tween := create_tween()
	tween.tween_property(_crank_sprite, "rotation_degrees", 0.0, Constants.reset_crank_seconds).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	velocity = - transform.y * (_crank_degrees / Constants.max_crank_degrees) * Constants.max_speed
