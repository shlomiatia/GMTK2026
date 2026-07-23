class_name Level extends Node2D

@export var attempts: int = 2

var _attempts_left: int
var _game_over: bool = false
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


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()


func _on_car_launched() -> void:
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


func _win() -> void:
	_game_over = true
	_overlay.show_message("You win! Press R to restart")


func _lose() -> void:
	_game_over = true
	_overlay.show_message("You lose! Press R to restart")
