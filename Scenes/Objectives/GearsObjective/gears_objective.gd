class_name GearsObjective extends Node

signal completed

var _total: int = 0
var _collected: int = 0


func _ready() -> void:
    var gears := get_tree().get_nodes_in_group("gear")
    _total = gears.size()
    for gear in gears:
        (gear as Gear).collected.connect(_on_gear_collected)


func _on_gear_collected() -> void:
    _collected += 1
    if _total > 0 && _collected >= _total:
        completed.emit()
