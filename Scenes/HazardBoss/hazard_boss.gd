class_name HazardBoss extends Node2D

signal died

const SPAWN_ATTEMPTS := 20

@export var hazard_scene: PackedScene
@export var bigger_hazard_scene: PackedScene
@export var biggest_hazard_scene: PackedScene

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _collision_shape: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _spawn_timer: Timer = $SpawnTimer
@onready var _core: BossCore = $BossCore

var _pending_hazards: Array = []


func _ready() -> void:
    _core.killed.connect(_die)
    _core.hit_taken.connect(_flash)
    _animation_player.animation_finished.connect(_on_animation_finished)
    _spawn_timer.wait_time = Constants.hazard_boss_spawn_interval
    _spawn_timer.timeout.connect(_on_spawn_timer_timeout)
    _spawn_timer.start()
    for i in range(Constants.hazard_boss_hazard_count):
        _spawn_hazard(false)


func is_dead() -> bool:
    return _core.is_dead()


func hit() -> bool:
    return _core.hit()


func _flash() -> void:
    _sprite.self_modulate = Color(1.0, 0.0, 0.0)
    var tween := create_tween()
    tween.tween_property(_sprite, "self_modulate", Color(1.0, 1.0, 1.0), Constants.boss_hit_flash_duration)


func get_radius() -> float:
    return (($StaticBody2D/CollisionShape2D as CollisionShape2D).shape as CircleShape2D).radius


func _die() -> void:
    _collision_shape.set_deferred("disabled", true)
    _animation_player.play("die")


func _on_animation_finished(anim_name: StringName) -> void:
    if anim_name == "die":
        died.emit()


func _on_spawn_timer_timeout() -> void:
    if _core.is_dead():
        return
    _despawn_random_hazard()
    _spawn_hazard(true)


func _despawn_random_hazard() -> void:
    var hazards := get_tree().get_nodes_in_group("hazard")
    if hazards.is_empty():
        return
    var hazard := hazards[randi() % hazards.size()] as Hazard
    hazard.despawn()


func _pick_hazard_scene() -> PackedScene:
    var roll := randf()
    if roll < 0.5:
        return hazard_scene
    if roll < 0.8:
        return bigger_hazard_scene
    return biggest_hazard_scene


func _spawn_hazard(start_disabled: bool) -> void:
    var arena := get_tree().get_first_node_in_group("arena") as Arena
    if !arena:
        return
    var hazard := _pick_hazard_scene().instantiate() as Hazard
    var hazard_radius := hazard.get_radius()
    var spawn_position: Variant = _find_spawn_position(arena, hazard_radius)
    if spawn_position == null:
        hazard.queue_free()
        return
    hazard.start_disabled = start_disabled
    hazard.global_position = spawn_position
    _pending_hazards.append({"position": spawn_position, "radius": hazard_radius})
    get_parent().add_child.call_deferred(hazard)


func _find_spawn_position(arena: Arena, hazard_radius: float) -> Variant:
    for attempt in range(SPAWN_ATTEMPTS):
        var angle := randf_range(0.0, TAU)
        var distance := sqrt(randf()) * maxf(arena.radius - hazard_radius, 0.0)
        var candidate := arena.global_position + Vector2(cos(angle), sin(angle)) * distance
        if _is_position_valid(candidate, hazard_radius):
            return candidate
    return null


func _is_position_valid(candidate: Vector2, hazard_radius: float) -> bool:
    var boss_radius := (_collision_shape.shape as CircleShape2D).radius
    if candidate.distance_to(global_position) < hazard_radius + boss_radius:
        return false
    for pillar in get_tree().get_nodes_in_group("pillar"):
        var p := pillar as Pillar
        if candidate.distance_to(p.global_position) < hazard_radius + p.radius:
            return false
    var car := get_tree().get_first_node_in_group("car") as Car
    if car && candidate.distance_to(car.global_position) < hazard_radius + car.get_bounding_radius():
        return false
    for other in get_tree().get_nodes_in_group("hazard"):
        var h := other as Hazard
        if candidate.distance_to(h.global_position) < hazard_radius + h.get_radius():
            return false
    for entry in _pending_hazards:
        if candidate.distance_to(entry["position"]) < hazard_radius + entry["radius"]:
            return false
    return true
