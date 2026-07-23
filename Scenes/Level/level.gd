class_name Level extends Node2D

@export var attempts: int = 2
@export var next_level: PackedScene

var _attempts_left: int
var _game_over: bool = false
var _won: bool = false
var _car: Car
var _goal: Goal

@onready var _overlay: Overlay = $Overlay


func _ready() -> void:
	_attempts_left = attempts
	_overlay.set_attempts(_attempts_left)
	_car = get_tree().get_first_node_in_group("car") as Car
	_goal = get_tree().get_first_node_in_group("goal") as Goal
	_car.launched.connect(_on_car_launched)
	_car.rested.connect(_on_car_rested)
	_car.steer_phase_started.connect(_on_car_steer_phase_started)
	_show_crank_hint()


func _process(_delta: float) -> void:
	if _won:
		return
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	if !_game_over && _is_car_out_of_bounds():
		_lose()


func _unhandled_input(event: InputEvent) -> void:
	if !_won:
		return
	if event.is_pressed() && !event.is_echo():
		_go_to_next_level()


func _on_car_launched() -> void:
	_overlay.hide_message()
	if _game_over:
		return
	_attempts_left -= 1
	_overlay.set_attempts(_attempts_left)


func _on_car_rested() -> void:
	if _game_over:
		return
	if _goal.has_car():
		_win()
	elif _attempts_left <= 0:
		_lose()
	else:
		_show_crank_hint()


func _on_car_steer_phase_started() -> void:
	_overlay.show_message("Click on crank and rotate to steer")


func _is_car_out_of_bounds() -> bool:
	var bounds := get_viewport().get_visible_rect().grow(_car.get_bounding_radius())
	return !bounds.has_point(_car.global_position)


func _show_crank_hint() -> void:
	if Constants.steering_mode == Constants.SteeringMode.ROTATION_CRANK:
		_overlay.show_message("Click on crank and rotate clockwise to set speed")


func _win() -> void:
	_game_over = true
	_won = true
	_overlay.show_message("You win! Press any key continue")


func _lose() -> void:
	_game_over = true
	_overlay.show_message("You lose! Press R to restart")


func _go_to_next_level() -> void:
	if next_level:
		get_tree().change_scene_to_packed(next_level)
