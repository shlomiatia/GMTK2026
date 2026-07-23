class_name Level extends Node2D

@export var time_limit: float = 10.0
@export var next_level: PackedScene

var _game_over: bool = false
var _won: bool = false
var _car: Car
var _goal: Goal
var _enemies: Array[Enemy] = []

@onready var _overlay: Overlay = $Overlay
@onready var _shaking_camera: ShakingCamera = $ShakingCamera
@onready var _timer: Timer = $Timer


func _ready() -> void:
    _timer.wait_time = time_limit
    _timer.timeout.connect(_on_timer_timeout)
    _timer.start()
    _car = get_tree().get_first_node_in_group("car") as Car
    _goal = get_tree().get_first_node_in_group("goal") as Goal
    _car.launched.connect(_on_car_launched)
    _car.rested.connect(_on_car_rested)
    _car.died.connect(_on_car_died)
    _car.enemy_killed.connect(_on_enemy_killed)
    for hazard in get_tree().get_nodes_in_group("hazard"):
        (hazard as Hazard).car_entered.connect(_on_car_entered_hazard)
    for enemy in get_tree().get_nodes_in_group("enemy"):
        _enemies.append(enemy as Enemy)


func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("skip_level"):
        _go_to_next_level()
        return
    if _won:
        return
    if Input.is_action_just_pressed("restart"):
        get_tree().reload_current_scene()
        return
    if _game_over:
        return
    _overlay.set_time(_timer.time_left)
    if _is_car_out_of_bounds():
        _lose()


func _unhandled_input(event: InputEvent) -> void:
    if !_won:
        return
    if event.is_pressed() && !event.is_echo():
        _go_to_next_level()

func _on_car_launched() -> void:
    _overlay.hide_message()


func _on_car_rested() -> void:
    if _game_over:
        return
    if _goal && _goal.has_car():
        _win()


func _on_timer_timeout() -> void:
    if _game_over:
        return
    _car.freeze()
    _lose()


func _on_enemy_killed(_enemy: Enemy) -> void:
    if _game_over:
        return
    _shaking_camera.start_screen_shake()
    if _all_enemies_dead():
        _win()


func _all_enemies_dead() -> bool:
    if _enemies.is_empty():
        return false
    for enemy in _enemies:
        if !enemy.is_dead():
            return false
    return true


func _on_car_entered_hazard(car: Car) -> void:
    if _game_over:
        return
    car.die()
    _shaking_camera.start_screen_shake()


func _on_car_died() -> void:
    if _game_over:
        return
    _lose()


func _is_car_out_of_bounds() -> bool:
    var bounds := get_viewport().get_visible_rect().grow(_car.get_bounding_radius())
    return !bounds.has_point(_car.global_position)


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
