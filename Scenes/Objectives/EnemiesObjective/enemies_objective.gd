class_name EnemiesObjective extends Node

signal completed

var _enemies: Array[Enemy] = []


func _ready() -> void:
    for enemy in get_tree().get_nodes_in_group("enemy"):
        var typed_enemy := enemy as Enemy
        _enemies.append(typed_enemy)
        typed_enemy.died.connect(_on_enemy_died)


func _on_enemy_died() -> void:
    for enemy in _enemies:
        if !enemy.is_dead():
            return
    completed.emit()
