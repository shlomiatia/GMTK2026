extends Node

const SAVE_PATH := "user://progress.cfg"

var completed_levels: Dictionary = {}
var auto_crank_enabled: bool = false


func _ready() -> void:
    _load()


func mark_completed(level_number: int) -> void:
    if completed_levels.has(level_number):
        return
    completed_levels[level_number] = true
    _save()


func is_completed(level_number: int) -> bool:
    return completed_levels.has(level_number)


func set_auto_crank(enabled: bool) -> void:
    auto_crank_enabled = enabled
    _save()


func _save() -> void:
    var config := ConfigFile.new()
    config.set_value("progress", "completed", completed_levels.keys())
    config.set_value("settings", "auto_crank", auto_crank_enabled)
    config.save(SAVE_PATH)


func _load() -> void:
    var config := ConfigFile.new()
    if config.load(SAVE_PATH) != OK:
        return
    completed_levels.clear()
    var completed: Array = config.get_value("progress", "completed", [])
    for level_number in completed:
        completed_levels[int(level_number)] = true
    auto_crank_enabled = config.get_value("settings", "auto_crank", false)
