class_name BossObjective extends Node

signal completed

var _bosses: Array[Node] = []


func _ready() -> void:
	for boss in get_tree().get_nodes_in_group("boss"):
		_bosses.append(boss)
		boss.connect("died", _on_boss_died)


func _on_boss_died() -> void:
	for boss in _bosses:
		if !boss.call("is_dead"):
			return
	completed.emit()
