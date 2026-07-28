extends Node

const SAVE_PATH := "user://progress.cfg"
const _cursor_texture := preload("res://Art/Assets/Cursor/Pinhole.png")

var unlocked_levels: Dictionary = {}
var auto_crank_enabled: bool = false


func _ready() -> void:
    Input.set_custom_mouse_cursor(_cursor_texture, Input.CURSOR_POINTING_HAND)
    _load()


func mark_unlocked(level_number: int) -> void:
    if unlocked_levels.has(level_number):
        return
    unlocked_levels[level_number] = true
    _save()


func is_unlocked(level_number: int) -> bool:
    return level_number == 1 || unlocked_levels.has(level_number)


func set_auto_crank(enabled: bool) -> void:
    auto_crank_enabled = enabled
    _save()


func _save() -> void:
    var config := ConfigFile.new()
    config.set_value("progress", "completed", unlocked_levels.keys())
    config.set_value("settings", "auto_crank", auto_crank_enabled)
    config.save(SAVE_PATH)


func _load() -> void:
    var config := ConfigFile.new()
    if config.load(SAVE_PATH) != OK:
        return
    unlocked_levels.clear()
    var completed: Array = config.get_value("progress", "completed", [])
    for level_number in completed:
        unlocked_levels[int(level_number)] = true
    auto_crank_enabled = config.get_value("settings", "auto_crank", false)
