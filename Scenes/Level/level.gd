@tool
class_name Level extends Node2D

static var time_progress_min_value := 3.33
static var time_progress_max_value := 96.67

@export var texture: Texture2D:
    set(value):
        texture = value
        if texture && is_node_ready():
            _sprite.texture = texture

var _game_over: bool = false
var _car: Car
var _goal: Goal
var _key_enemies: Array[Enemy] = []
var _keys: Array[Collectible] = []
var _gear_time_tween: Tween

@onready var _overlay: Overlay = $Overlay
@onready var _shaking_camera: ShakingCamera = $ShakingCamera
@onready var _timer: Timer = $Timer
@onready var _time_progress_bar: TextureProgressBar = $Time
@onready var _sprite: Sprite2D = $Sprite2D
@onready var _level_skip: LevelSkip = $LevelSkip


func _ready() -> void:
    if texture:
        _sprite.texture = texture
    if Engine.is_editor_hint():
        return
    _timer.wait_time = Constants.default_level_time
    _timer.timeout.connect(_on_timer_timeout)
    _timer.start()
    _car = get_tree().get_first_node_in_group("car") as Car
    _car.launched.connect(_on_car_launched)
    _car.died.connect(_on_car_died)
    _car.enemy_killed.connect(_on_enemy_killed)
    _car.cannon_killed.connect(_on_cannon_killed)
    _car.boss_hit.connect(_on_boss_hit)
    _goal = get_tree().get_first_node_in_group("goal") as Goal
    for enemy in get_tree().get_nodes_in_group("enemy"):
        if (enemy as Enemy).key:
            _key_enemies.append(enemy)
    for key in get_tree().get_nodes_in_group("key"):
        _keys.append(key as Collectible)
        (key as Collectible).collected.connect(_on_key_collected.bind(key))
    if !_key_enemies.is_empty() || !_keys.is_empty():
        _goal.lock.call_deferred()
    get_tree().get_first_node_in_group("objective").completed.connect(_win)
    for hazard in get_tree().get_nodes_in_group("hazard"):
        (hazard as Hazard).car_entered.connect(_on_car_entered_hazard)
    get_tree().node_added.connect(_on_node_added)
    for gear in get_tree().get_nodes_in_group("gear"):
        (gear as Collectible).collected.connect(_on_gear_collected)
    for cannon in get_tree().get_nodes_in_group("cannon"):
        (cannon as Cannon).fired.connect(_on_cannon_fired)
    for boss in get_tree().get_nodes_in_group("boss"):
        var cannon_boss := boss as CannonBoss
        if cannon_boss:
            cannon_boss.fired.connect(_on_cannon_fired)
        var sub_boss := boss as SubBoss
        if sub_boss:
            sub_boss.car_hit.connect(_on_sub_boss_car_hit)
        var final_boss := boss as FinalBoss
        if final_boss:
            final_boss.car_hit.connect(_on_final_boss_car_hit)
    if get_tree().get_nodes_in_group("boss").is_empty():
        MusicPlayer.set_boss_level(false, Constants.music_fade_seconds)
    else:
        MusicPlayer.fade_out_level_music(Constants.boss_intro_music_fade_seconds)
    _overlay.restart_pressed.connect(_restart)
    _overlay.win_confirmed.connect(_on_win_confirmed)
    _level_skip.skip_requested.connect(_go_to_next_level)


func _process(_delta: float) -> void:
    if Engine.is_editor_hint():
        return
    if Input.is_action_just_pressed("restart"):
        _restart()
        return
    if _game_over:
        return
    _time_progress_bar.value = lerpf(time_progress_min_value, time_progress_max_value, _timer.time_left / Constants.default_level_time)
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
    _add_time_bonus(Constants.enemy_kill_time_bonus)
    if enemy.key:
        _key_enemies.erase(enemy)
        _try_unlock_goal()


func _on_cannon_killed(_cannon: Cannon) -> void:
    if _game_over:
        return
    _shaking_camera.start_screen_shake()
    _add_time_bonus(Constants.cannon_kill_time_bonus)


func _on_boss_hit(_boss: Node) -> void:
    if _game_over:
        return
    _shaking_camera.start_screen_shake()


func _on_sub_boss_car_hit() -> void:
    if _game_over:
        return
    _shaking_camera.start_screen_shake()


func _on_final_boss_car_hit() -> void:
    if _game_over:
        return
    _shaking_camera.start_screen_shake()


func _on_key_collected(key: Collectible) -> void:
    if _game_over:
        return
    _keys.erase(key)
    _try_unlock_goal()


func _try_unlock_goal() -> void:
    if _key_enemies.is_empty() && _keys.is_empty():
        _goal.unlock()


func _on_node_added(node: Node) -> void:
    if node.is_in_group("hazard"):
        (node as Hazard).car_entered.connect(_on_car_entered_hazard)
    elif node.is_in_group("gear"):
        (node as Collectible).collected.connect(_on_gear_collected)
    elif node.is_in_group("bullet"):
        (node as Bullet).car_hit.connect(_on_bullet_car_hit)
    elif node.is_in_group("cannon"):
        (node as Cannon).fired.connect(_on_cannon_fired)
    elif node.is_in_group("boss"):
        var cannon_boss := node as CannonBoss
        if cannon_boss:
            cannon_boss.fired.connect(_on_cannon_fired)
        var sub_boss := node as SubBoss
        if sub_boss:
            sub_boss.car_hit.connect(_on_sub_boss_car_hit)
        var final_boss := node as FinalBoss
        if final_boss:
            final_boss.car_hit.connect(_on_final_boss_car_hit)


func _on_car_entered_hazard(car: Car) -> void:
    if _game_over:
        return
    car.die()
    _shaking_camera.start_screen_shake()


func _on_bullet_car_hit(_c: Car) -> void:
    if _game_over:
        return
    _shaking_camera.start_screen_shake()


func _on_cannon_fired() -> void:
    if _game_over:
        return
    _shaking_camera.start_screen_shake()


func _on_gear_collected() -> void:
    if _game_over:
        return
    _add_time_bonus(Constants.gear_time_bonus)


func _add_time_bonus(amount: float) -> void:
    if _gear_time_tween:
        _gear_time_tween.kill()
    _timer.paused = true
    var target_time: float = minf(_timer.time_left + amount, Constants.default_level_time)
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
    get_tree().paused = true
    GameState.mark_completed(_current_level_number())
    if ResourceLoader.exists(_next_level_path()):
        _go_to_next_level()
    else:
        _overlay.show_win()


func _lose() -> void:
    _game_over = true
    _overlay.show_lose()


func _restart() -> void:
    get_tree().reload_current_scene()


func _go_to_next_level() -> void:
    var next_level_path := _next_level_path()
    if ResourceLoader.exists(next_level_path):
        SceneTransition.transition_to_scene(next_level_path)


func _next_level_path() -> String:
    var current_path := get_tree().current_scene.scene_file_path
    var levels_dir := current_path.get_base_dir().get_base_dir()
    return "%s/Level%d/Level.tscn" % [levels_dir, _current_level_number() + 1]


func _current_level_number() -> int:
    var current_path := get_tree().current_scene.scene_file_path
    return current_path.get_base_dir().get_file().trim_prefix("Level").to_int()


func _on_win_confirmed() -> void:
    SceneTransition.transition_to_scene("res://Scenes/TitleScreen/TitleScreen.tscn")
