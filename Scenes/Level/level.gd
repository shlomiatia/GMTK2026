@tool
class_name Level extends Node2D

@export var time_limit: float = 10.0
@export var texture: Texture2D:
    set(value):
        texture = value
        if texture && is_node_ready():
            _sprite.texture = texture

var _game_over: bool = false
var _won: bool = false
var _car: Car

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
    get_tree().get_first_node_in_group("objective").completed.connect(_win)
    for hazard in get_tree().get_nodes_in_group("hazard"):
        (hazard as Hazard).car_entered.connect(_on_car_entered_hazard)
    for gear in get_tree().get_nodes_in_group("gear"):
        (gear as Gear).collected.connect(_on_gear_collected)


func _process(_delta: float) -> void:
    if Engine.is_editor_hint():
        return
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
    _time_progress_bar.value = lerpf(Constants.time_progress_min_value, Constants.time_progress_max_value, _timer.time_left / time_limit)
    if _is_car_out_of_bounds():
        _lose()


func _unhandled_input(event: InputEvent) -> void:
    if Engine.is_editor_hint():
        return
    if !_won:
        return
    if event.is_pressed() && !event.is_echo():
        _go_to_next_level()


func _on_car_launched() -> void:
    _overlay.hide_message()


func _on_timer_timeout() -> void:
    if _game_over:
        return
    _car.freeze()
    _lose()


func _on_enemy_killed(_enemy: Enemy) -> void:
    if _game_over:
        return
    _shaking_camera.start_screen_shake()


func _on_car_entered_hazard(car: Car) -> void:
    if _game_over:
        return
    car.die()
    _shaking_camera.start_screen_shake()


func _on_gear_collected() -> void:
    if _game_over:
        return
    _timer.start(_timer.time_left + Constants.gear_time_bonus)


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
    _won = true
    _overlay.show_message("You win! Press any key continue")


func _lose() -> void:
    _game_over = true
    _overlay.show_message("You lose! Press R to restart")


func _go_to_next_level() -> void:
    var current_path := get_tree().current_scene.scene_file_path
    var levels_dir := current_path.get_base_dir().get_base_dir()
    var level_number := current_path.get_base_dir().get_file().trim_prefix("Level").to_int()
    var next_level_path := "%s/Level%d/Level.tscn" % [levels_dir, level_number + 1]
    if ResourceLoader.exists(next_level_path):
        get_tree().change_scene_to_file(next_level_path)
