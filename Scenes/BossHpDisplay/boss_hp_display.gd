class_name BossHpDisplay extends Sprite2D

@export var hp_textures: Array[Texture2D] = []


func _ready() -> void:
    var core := get_parent() as BossCore
    if core:
        core.hp_changed.connect(set_hits_remaining)


func set_hits_remaining(remaining: int) -> void:
    if remaining < 0 || remaining >= hp_textures.size():
        return
    texture = hp_textures[remaining]
