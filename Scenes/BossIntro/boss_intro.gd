extends Node

@onready var _boss: Node2D = get_parent() as Node2D
@onready var _point_light: PointLight2D = _boss.find_child("PointLight2D", true, false) as PointLight2D
@onready var _canvas_modulate: CanvasModulate = _boss.find_child("CanvasModulate", true, false) as CanvasModulate
@onready var _boss_core: BossCore = _boss.find_child("BossCore", true, false) as BossCore


func _ready() -> void:
    _boss_core.killed.connect(_on_boss_killed)
    if MusicPlayer.boss_active && MusicPlayer.active_boss_path == _boss.scene_file_path:
        _skip_intro()
        _end_intro()
        return
    if MusicPlayer.boss_active:
        MusicPlayer.stop_boss_music(Constants.boss_intro_music_fade_seconds)
    MusicPlayer.active_boss_path = _boss.scene_file_path
    get_tree().paused = true
    _boss.process_mode = Node.PROCESS_MODE_PAUSABLE
    var tween := create_tween()
    tween.tween_interval(Constants.boss_intro_delay_seconds)
    tween.tween_property(_point_light, "energy", Constants.boss_intro_flicker_energy, Constants.boss_intro_flicker_up_seconds)
    tween.tween_property(_point_light, "energy", 0.0, Constants.boss_intro_flicker_down_seconds)
    tween.tween_interval(Constants.boss_intro_flicker_pause_seconds)
    tween.set_parallel(true)
    tween.tween_property(_point_light, "energy", Constants.boss_intro_peak_energy, Constants.boss_intro_rise_seconds)
    tween.tween_property(_canvas_modulate, "color", Color(1, 1, 1, 1), Constants.boss_intro_glow_seconds).set_delay(Constants.boss_intro_glow_delay_seconds)
    tween.tween_callback(_start_music).set_delay(Constants.boss_intro_glow_delay_seconds)
    tween.set_parallel(false)
    tween.tween_callback(_end_intro)


func _skip_intro() -> void:
    _point_light.energy = Constants.boss_intro_peak_energy
    _canvas_modulate.color = Color(1, 1, 1, 1)


func _start_music() -> void:
    MusicPlayer.set_boss_level(true, Constants.boss_intro_music_fade_seconds)


func _end_intro() -> void:
    _boss.process_mode = Node.PROCESS_MODE_ALWAYS
    get_tree().paused = false


func _on_boss_killed() -> void:
    var tween := create_tween()
    tween.tween_property(_point_light, "energy", 0.0, Constants.boss_intro_death_fade_seconds)
