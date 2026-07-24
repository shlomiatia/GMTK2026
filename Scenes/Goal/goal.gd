class_name Goal extends Node2D

signal car_entered

@export var locked: bool = false

@onready var _area: Area2D = $Area2D
@onready var _locked_sprite: Sprite2D = $Locked
@onready var _animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
    _locked_sprite.visible = locked
    _area.area_entered.connect(_on_area_entered)


func has_car() -> bool:
    if locked:
        return false
    for area in _area.get_overlapping_areas():
        if area.get_collision_layer_value(CollisionLayers.CAR_SENSOR):
            return true
    return false


func lock() -> void:
    locked = true
    _locked_sprite.visible = true


func unlock() -> void:
    if !locked:
        return
    locked = false
    _animation_player.play("unlock")
    if has_car():
        car_entered.emit()


func _on_area_entered(area: Area2D) -> void:
    if locked:
        return
    if area.get_collision_layer_value(CollisionLayers.CAR_SENSOR):
        car_entered.emit()
