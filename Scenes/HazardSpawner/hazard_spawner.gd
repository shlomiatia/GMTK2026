class_name HazardSpawner extends Node

signal hazard_spawned

const SPAWN_ATTEMPTS := 20
const FIXED_HAZARDS := [
    {"size": "bigger", "position": Vector2(742, 165)},
    {"size": "bigger", "position": Vector2(1173, 161)},
    {"size": "normal", "position": Vector2(749, 388)},
    {"size": "normal", "position": Vector2(1165, 389)},
    {"size": "normal", "position": Vector2(880, 397)},
    {"size": "normal", "position": Vector2(1045, 391)},
]

@export var hazard_scene: PackedScene
@export var bigger_hazard_scene: PackedScene
@export var biggest_hazard_scene: PackedScene
@export var hazard_chance: float = 0.5
@export var bigger_hazard_chance: float = 0.3

@onready var _spawn_timer: Timer = $SpawnTimer
@onready var _boss: Node2D = get_parent() as Node2D

var _pending_hazards: Array = []


func _ready() -> void:
    _spawn_timer.wait_time = Constants.hazard_spawner_interval
    _spawn_timer.timeout.connect(_on_spawn_timer_timeout)
    _spawn_timer.start()
    for i in range(Constants.hazard_spawner_hazard_count):
        _spawn_hazard(false)


func _on_spawn_timer_timeout() -> void:
    if _boss.call("is_dead"):
        return
    _pending_hazards.clear()
    _despawn_random_hazard()
    if _spawn_hazard(true):
        hazard_spawned.emit()


func spawn_fixed_wave() -> void:
    _pending_hazards.clear()
    for hazard in get_tree().get_nodes_in_group("hazard"):
        (hazard as Hazard).despawn()
    for entry in FIXED_HAZARDS:
        var scene: PackedScene = bigger_hazard_scene if entry["size"] == "bigger" else hazard_scene
        _spawn_hazard_at(scene, entry["position"])
    _spawn_timer.start()


func _spawn_hazard_at(scene: PackedScene, spawn_position: Vector2) -> void:
    var hazard := scene.instantiate() as Hazard
    hazard.start_disabled = true
    hazard.global_position = spawn_position
    _boss.get_parent().add_child.call_deferred(hazard)


func _despawn_random_hazard() -> void:
    var hazards := get_tree().get_nodes_in_group("hazard")
    if hazards.is_empty():
        return
    var hazard := hazards[randi() % hazards.size()] as Hazard
    hazard.despawn()


func _pick_hazard_scene() -> PackedScene:
    var roll := randf()
    if roll < hazard_chance:
        return hazard_scene
    if roll < hazard_chance + bigger_hazard_chance:
        return bigger_hazard_scene
    return biggest_hazard_scene


func _spawn_hazard(start_disabled: bool) -> bool:
    var arena := get_tree().get_first_node_in_group("arena") as Arena
    if !arena:
        return false
    var hazard := _pick_hazard_scene().instantiate() as Hazard
    var hazard_radius := hazard.get_radius()
    var spawn_position: Variant = _find_spawn_position(arena, hazard_radius)
    if spawn_position == null:
        hazard.queue_free()
        return false
    hazard.start_disabled = start_disabled
    hazard.global_position = spawn_position
    _pending_hazards.append({"position": spawn_position, "radius": hazard_radius})
    _boss.get_parent().add_child.call_deferred(hazard)
    return true


func _find_spawn_position(arena: Arena, hazard_radius: float) -> Variant:
    for attempt in range(SPAWN_ATTEMPTS):
        var angle := randf_range(0.0, TAU)
        var distance := sqrt(randf()) * maxf(arena.radius - hazard_radius, 0.0)
        var candidate := arena.global_position + Vector2(cos(angle), sin(angle)) * distance
        if _is_position_valid(candidate, hazard_radius):
            return candidate
    return null


func _is_position_valid(candidate: Vector2, hazard_radius: float) -> bool:
    var boss_radius: float = _boss.call("get_radius")
    if candidate.distance_to(_boss.global_position) < hazard_radius + boss_radius:
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
