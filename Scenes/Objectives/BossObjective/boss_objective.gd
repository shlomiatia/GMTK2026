class_name BossObjective extends Node

signal completed

var _bosses: Array[MinionBoss] = []


func _ready() -> void:
	for boss in get_tree().get_nodes_in_group("boss"):
		var typed_boss := boss as MinionBoss
		_bosses.append(typed_boss)
		typed_boss.died.connect(_on_boss_died)


func _on_boss_died() -> void:
	for boss in _bosses:
		if !boss.is_dead():
			return
	completed.emit()
