class_name Options extends CanvasLayer

@onready var _max_crank_degrees_spin_box: SpinBox = $Center/Panel/Margin/VBox/MaxCrankDegreesRow/SpinBox
@onready var _max_speed_spin_box: SpinBox = $Center/Panel/Margin/VBox/MaxSpeedRow/SpinBox
@onready var _friction_spin_box: SpinBox = $Center/Panel/Margin/VBox/FrictionRow/SpinBox
@onready var _reset_crank_seconds_spin_box: SpinBox = $Center/Panel/Margin/VBox/ResetCrankSecondsRow/SpinBox
@onready var _distance_label: Label = $Center/Panel/Margin/VBox/DistanceLabel
@onready var _steer_speed_spin_box: SpinBox = $Center/Panel/Margin/VBox/SteerSpeedRow/SpinBox


func _ready() -> void:
	_max_crank_degrees_spin_box.value = Constants.max_crank_degrees
	_max_speed_spin_box.value = Constants.max_speed
	_friction_spin_box.value = Constants.friction
	_reset_crank_seconds_spin_box.value = Constants.reset_crank_seconds
	_steer_speed_spin_box.value = Constants.steer_speed
	_update_distance_label()


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


func _on_steer_speed_spin_box_value_changed(value: float) -> void:
	Constants.steer_speed = value
