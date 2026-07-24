@tool
class_name Level extends Node2D

@export var time_limit: float = 15.0
@export var texture: Texture2D:
    set(value):
        texture = value
        if texture && is_node_ready():
            _sprite.texture = texture

var _game_over: bool = false
var _car: Car
var _goal: Goal
var _key_enemies: Array[Enemy] = []
var _keys: Array[Key] = []
var _gear_time_tween: Tween

@onready var _overlay: Overlay = $Overlay
@onready var _shaking_camera: ShakingCamera = $ShakingCamera
@onready var _timer: Timer = $Timer
@onready var _time_progress_bar: TextureProgressBar = $Time
@onready var _sprite: Sprite2D = $Sprite2D


func _ready() -> void:
    if texture:
        _sprite.texture = texture
    if Engine.is_editor_hint():
        return
    _timer.wait_time = time_limit
    _timer.timeout.connect(_on_timer_timeout)
    _timer.start()
    _car = get_tree().get_first_node_in_group("car") as Car
    _car.launched.connect(_on_car_launched)
    _car.died.connect(_on_car_died)
    _car.enemy_killed.connect(_on_enemy_killed)
    _goal = get_tree().get_first_node_in_group("goal") as Goal
    for enemy in get_tree().get_nodes_in_group("enemy"):
        if (enemy as Enemy).key:
            _key_enemies.append(enemy)
    for key in get_tree().get_nodes_in_group("key"):
        _keys.append(key as Key)
        (key as Key).collected.connect(_on_key_collected.bind(key))
    if !_key_enemies.is_empty() || !_keys.is_empty():
        _goal.lock.call_deferred()
    get_tree().get_first_node_in_group("objective").completed.connect(_win)
    for hazard in get_tree().get_nodes_in_group("hazard"):
        (hazard as Hazard).car_entered.connect(_on_car_entered_hazard)
    for gear in get_tree().get_nodes_in_group("gear"):
        (gear as Gear).collected.connect(_on_gear_collected)
    _overlay.continue_pressed.connect(_go_to_next_level)
    _overlay.restart_pressed.connect(_restart)


func _process(_delta: float) -> void:
    if Engine.is_editor_hint():
        return
    if Input.is_action_just_pressed("skip_level"):
        _go_to_next_level()
        return
    if _game_over:
        return
    _time_progress_bar.value = lerpf(Constants.time_progress_min_value, Constants.time_progress_max_value, _timer.time_left / time_limit)
    if _is_car_out_of_bounds():
        _lose()


func _on_car_launched() -> void:
    _overlay.hide_message()


func _on_timer_timeout() -> void:
    if _game_over:
        return
    _lose()


func _on_enemy_killed(enemy: Enemy) -> void:
    if _game_over:
        return
    _shaking_camera.start_screen_shake()
    if enemy.key:
        _key_enemies.erase(enemy)
        _try_unlock_goal()


func _on_key_collected(key: Key) -> void:
    if _game_over:
        return
    _keys.erase(key)
    _try_unlock_goal()


func _try_unlock_goal() -> void:
    if _key_enemies.is_empty() && _keys.is_empty():
        _goal.unlock()


func _on_car_entered_hazard(car: Car) -> void:
    if _game_over:
        return
    car.die()
    _shaking_camera.start_screen_shake()


func _on_gear_collected() -> void:
    if _game_over:
        return
    if _gear_time_tween:
        _gear_time_tween.kill()
    _timer.paused = true
    var target_time: float = minf(_timer.time_left + Constants.gear_time_bonus, time_limit)
    _gear_time_tween = create_tween()
    _gear_time_tween.tween_method(_set_timer_time, _timer.time_left, target_time, 0.5)
    _gear_time_tween.finished.connect(_on_gear_time_tween_finished)


func _set_timer_time(time: float) -> void:
    _timer.start(time)


func _on_gear_time_tween_finished() -> void:
    _timer.paused = false


func _on_car_died() -> void:
    if _game_over:
        return
    _lose()


func _is_car_out_of_bounds() -> bool:
    var bounds := get_viewport().get_visible_rect().grow(_car.get_bounding_radius())
    return !bounds.has_point(_car.global_position)


func _win() -> void:
    if _game_over:
        return
    _game_over = true
    _overlay.show_win()


func _lose() -> void:
    _game_over = true
    _overlay.show_lose()


func _restart() -> void:
    get_tree().reload_current_scene()


func _go_to_next_level() -> void:
    var current_path := get_tree().current_scene.scene_file_path
    var levels_dir := current_path.get_base_dir().get_base_dir()
    var level_number := current_path.get_base_dir().get_file().trim_prefix("Level").to_int()
    var next_level_path := "%s/Level%d/Level.tscn" % [levels_dir, level_number + 1]
    if ResourceLoader.exists(next_level_path):
        get_tree().paused = false
        get_tree().change_scene_to_file(next_level_path)
