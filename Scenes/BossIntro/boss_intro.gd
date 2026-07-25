extends Node

@onready var _boss: Node2D = get_parent() as Node2D
@onready var _point_light: PointLight2D = _boss.get_node("PointLight2D") as PointLight2D
@onready var _point_light_glow: PointLight2D = _boss.get_node("PointLight2D2") as PointLight2D


func _ready() -> void:
    get_tree().paused = true
    _boss.process_mode = Node.PROCESS_MODE_PAUSABLE
    var tween := create_tween()
    tween.tween_interval(Constants.boss_intro_delay_seconds)
    tween.tween_property(_point_light, "energy", Constants.boss_intro_flicker_energy, Constants.boss_intro_flicker_seconds)
    tween.tween_property(_point_light, "energy", 0.0, Constants.boss_intro_flicker_seconds)
    tween.tween_property(_point_light, "energy", Constants.boss_intro_peak_energy, Constants.boss_intro_rise_seconds)
    tween.tween_callback(_start_music)
    tween.tween_property(_point_light_glow, "scale", Vector2(Constants.boss_intro_glow_scale, Constants.boss_intro_glow_scale), Constants.boss_intro_glow_seconds)
    tween.tween_callback(_end_intro)


func _start_music() -> void:
    MusicPlayer.set_boss_level(true)


func _end_intro() -> void:
    _boss.process_mode = Node.PROCESS_MODE_ALWAYS
    get_tree().paused = false
