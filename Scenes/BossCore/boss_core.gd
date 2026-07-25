class_name BossCore extends Node

signal killed

@export var hits_to_kill: int = 3
@export var invincibility_duration: float = 0.5

@onready var _invincibility_timer: Timer = $InvincibilityTimer

var _hits_taken: int = 0
var _is_dead: bool = false
var _is_invincible: bool = false


func _ready() -> void:
    _invincibility_timer.wait_time = invincibility_duration
    _invincibility_timer.timeout.connect(_on_invincibility_timer_timeout)


func is_dead() -> bool:
    return _is_dead


func hit() -> bool:
    if _is_dead || _is_invincible:
        return false
    _hits_taken += 1
    if _hits_taken >= hits_to_kill:
        _is_dead = true
        get_tree().paused = true
        killed.emit()
        return true
    _is_invincible = true
    _invincibility_timer.start()
    return true


func _on_invincibility_timer_timeout() -> void:
    _is_invincible = false
