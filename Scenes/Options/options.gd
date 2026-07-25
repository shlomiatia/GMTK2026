class_name Options extends CanvasLayer

var original_paused_state = false

@onready var _max_crank_degrees_spin_box: SpinBox = $Center/Panel/Margin/VBox/MaxCrankDegreesRow/SpinBox
@onready var _max_speed_spin_box: SpinBox = $Center/Panel/Margin/VBox/MaxSpeedRow/SpinBox
@onready var _friction_spin_box: SpinBox = $Center/Panel/Margin/VBox/FrictionRow/SpinBox
@onready var _distance_label: Label = $Center/Panel/Margin/VBox/DistanceLabel
@onready var _steer_speed_spin_box: SpinBox = $Center/Panel/Margin/VBox/SteerSpeedRow/SpinBox
@onready var _enemy_speed_spin_box: SpinBox = $Center/Panel/Margin/VBox/EnemySpeedRow/SpinBox
@onready var _enemy_kill_speed_spin_box: SpinBox = $Center/Panel/Margin/VBox/EnemyKillSpeedRow/SpinBox
@onready var _gear_time_bonus_spin_box: SpinBox = $Center/Panel/Margin/VBox/GearTimeBonusRow/SpinBox
@onready var _enemy_kill_time_bonus_spin_box: SpinBox = $Center/Panel/Margin/VBox/EnemyKillTimeBonusRow/SpinBox
@onready var _cannon_kill_time_bonus_spin_box: SpinBox = $Center/Panel/Margin/VBox/CannonKillTimeBonusRow/SpinBox
@onready var _cannon_turret_speed_degrees_spin_box: SpinBox = $Center/Panel/Margin/VBox/CannonTurretSpeedDegreesRow/SpinBox
@onready var _bullet_speed_spin_box: SpinBox = $Center/Panel/Margin/VBox/BulletSpeedRow/SpinBox


func _ready() -> void:
    _max_crank_degrees_spin_box.value = Constants.max_crank_degrees
    _max_speed_spin_box.value = Constants.max_speed
    _friction_spin_box.value = Constants.friction
    _steer_speed_spin_box.value = Constants.steer_speed
    _enemy_speed_spin_box.value = Constants.enemy_speed
    _enemy_kill_speed_spin_box.value = Constants.enemy_kill_speed
    _gear_time_bonus_spin_box.value = Constants.gear_time_bonus
    _enemy_kill_time_bonus_spin_box.value = Constants.enemy_kill_time_bonus
    _cannon_kill_time_bonus_spin_box.value = Constants.cannon_kill_time_bonus
    _cannon_turret_speed_degrees_spin_box.value = Constants.cannon_turret_speed_degrees
    _bullet_speed_spin_box.value = Constants.bullet_speed
    _update_distance_label()


func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("options"):
        visible = !visible
        if visible:
            original_paused_state = get_tree().paused
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
            get_tree().paused = true
        else:
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
            get_tree().paused = original_paused_state


func _on_max_crank_degrees_spin_box_value_changed(value: float) -> void:
    Constants.max_crank_degrees = value


func _on_max_speed_spin_box_value_changed(value: float) -> void:
    Constants.max_speed = value
    _update_distance_label()


func _on_friction_spin_box_value_changed(value: float) -> void:
    Constants.friction = value
    _update_distance_label()


func _update_distance_label() -> void:
    var distance := (Constants.max_speed * Constants.max_speed) / (2.0 * Constants.friction)
    _distance_label.text = "Estimated max travel distance: %d px" % distance


func _on_steer_speed_spin_box_value_changed(value: float) -> void:
    Constants.steer_speed = value


func _on_enemy_speed_spin_box_value_changed(value: float) -> void:
    Constants.enemy_speed = value


func _on_enemy_kill_speed_spin_box_value_changed(value: float) -> void:
    Constants.enemy_kill_speed = value


func _on_gear_time_bonus_spin_box_value_changed(value: float) -> void:
    Constants.gear_time_bonus = value


func _on_enemy_kill_time_bonus_spin_box_value_changed(value: float) -> void:
    Constants.enemy_kill_time_bonus = value


func _on_cannon_kill_time_bonus_spin_box_value_changed(value: float) -> void:
    Constants.cannon_kill_time_bonus = value


func _on_cannon_turret_speed_degrees_spin_box_value_changed(value: float) -> void:
    Constants.cannon_turret_speed_degrees = value


func _on_bullet_speed_spin_box_value_changed(value: float) -> void:
    Constants.bullet_speed = value
