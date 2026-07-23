class_name Options extends CanvasLayer

@onready var _max_crank_degrees_spin_box: SpinBox = $Center/Panel/Margin/VBox/MaxCrankDegreesRow/SpinBox
@onready var _max_speed_spin_box: SpinBox = $Center/Panel/Margin/VBox/MaxSpeedRow/SpinBox
@onready var _friction_spin_box: SpinBox = $Center/Panel/Margin/VBox/FrictionRow/SpinBox
@onready var _reset_crank_seconds_spin_box: SpinBox = $Center/Panel/Margin/VBox/ResetCrankSecondsRow/SpinBox
@onready var _distance_label: Label = $Center/Panel/Margin/VBox/DistanceLabel
@onready var _steering_mode_rotate_on_start: CheckBox = $Center/Panel/Margin/VBox/SteeringModeRotateOnStart
@onready var _steering_mode_free_steering: CheckBox = $Center/Panel/Margin/VBox/SteeringModeFreeSteering
@onready var _steering_mode_rotation_crank: CheckBox = $Center/Panel/Margin/VBox/SteeringModeRotationCrank
@onready var _rotate_speed_spin_box: SpinBox = $Center/Panel/Margin/VBox/RotateSpeedRow/SpinBox
@onready var _steer_speed_spin_box: SpinBox = $Center/Panel/Margin/VBox/SteerSpeedRow/SpinBox
@onready var _max_steer_crank_rotations_spin_box: SpinBox = $Center/Panel/Margin/VBox/MaxSteerCrankRotationsRow/SpinBox


func _ready() -> void:
	_max_crank_degrees_spin_box.value = Constants.max_crank_degrees
	_max_speed_spin_box.value = Constants.max_speed
	_friction_spin_box.value = Constants.friction
	_reset_crank_seconds_spin_box.value = Constants.reset_crank_seconds
	_rotate_speed_spin_box.value = Constants.rotate_speed
	_steer_speed_spin_box.value = Constants.steer_speed
	_max_steer_crank_rotations_spin_box.value = Constants.max_steer_crank_rotations
	_update_distance_label()
	_steering_mode_rotate_on_start.button_pressed = Constants.rotate_on_start
	match Constants.steering_mode:
		Constants.SteeringMode.FREE_STEERING:
			_steering_mode_free_steering.button_pressed = true
		Constants.SteeringMode.ROTATION_CRANK:
			_steering_mode_rotation_crank.button_pressed = true


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("options"):
		visible = !visible
		get_tree().paused = visible


func _on_max_crank_degrees_spin_box_value_changed(value: float) -> void:
	Constants.max_crank_degrees = value


func _on_max_speed_spin_box_value_changed(value: float) -> void:
	Constants.max_speed = value
	_update_distance_label()


func _on_friction_spin_box_value_changed(value: float) -> void:
	Constants.friction = value
	_update_distance_label()


func _on_reset_crank_seconds_spin_box_value_changed(value: float) -> void:
	Constants.reset_crank_seconds = value


func _update_distance_label() -> void:
	var distance := (Constants.max_speed * Constants.max_speed) / (2.0 * Constants.friction)
	_distance_label.text = "Estimated max travel distance: %d px" % distance


func _on_rotate_speed_spin_box_value_changed(value: float) -> void:
	Constants.rotate_speed = value


func _on_steer_speed_spin_box_value_changed(value: float) -> void:
	Constants.steer_speed = value


func _on_max_steer_crank_rotations_spin_box_value_changed(value: float) -> void:
	Constants.max_steer_crank_rotations = value


func _on_steering_mode_rotate_on_start_toggled(button_pressed: bool) -> void:
	if Constants.rotate_on_start == button_pressed:
		return
	Constants.rotate_on_start = button_pressed
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_steering_mode_free_steering_toggled(button_pressed: bool) -> void:
	if button_pressed:
		_set_steering_mode(Constants.SteeringMode.FREE_STEERING)


func _on_steering_mode_rotation_crank_toggled(button_pressed: bool) -> void:
	if button_pressed:
		_set_steering_mode(Constants.SteeringMode.ROTATION_CRANK)


func _set_steering_mode(mode: Constants.SteeringMode) -> void:
	if Constants.steering_mode == mode:
		return
	Constants.steering_mode = mode
	get_tree().paused = false
	get_tree().reload_current_scene()
