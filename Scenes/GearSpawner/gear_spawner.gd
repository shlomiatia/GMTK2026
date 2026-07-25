class_name GearSpawner extends Node

const SPAWN_ATTEMPTS := 20

@export var gear_scene: PackedScene

@onready var _spawn_timer: Timer = $SpawnTimer
@onready var _boss: Node2D = get_parent() as Node2D

var _pending_gears: Array = []


func _ready() -> void:
    _spawn_timer.wait_time = Constants.gear_spawner_interval
    _spawn_timer.timeout.connect(_on_spawn_timer_timeout)
    _spawn_timer.start()
    for i in range(Constants.gear_spawner_initial_count):
        _spawn_gear()


func _on_spawn_timer_timeout() -> void:
    if _boss.call("is_dead"):
        return
    _spawn_gear()


func _spawn_gear() -> void:
    var arena := get_tree().get_first_node_in_group("arena") as Arena
    if !arena:
        return
    var gear := gear_scene.instantiate() as Collectible
    var gear_radius := gear.get_radius()
    var spawn_position: Variant = _find_spawn_position(arena, gear_radius)
    if spawn_position == null:
        gear.queue_free()
        return
    gear.global_position = spawn_position
    _pending_gears.append({"position": spawn_position, "radius": gear_radius})
    _boss.get_parent().add_child.call_deferred(gear)


func _find_spawn_position(arena: Arena, gear_radius: float) -> Variant:
    for attempt in range(SPAWN_ATTEMPTS):
        var angle := randf_range(0.0, TAU)
        var distance := sqrt(randf()) * maxf(arena.radius - gear_radius, 0.0)
        var candidate := arena.global_position + Vector2(cos(angle), sin(angle)) * distance
        if _is_position_valid(candidate, gear_radius):
            return candidate
    return null


func _is_position_valid(candidate: Vector2, gear_radius: float) -> bool:
    for boss in get_tree().get_nodes_in_group("boss"):
        if !boss.has_method("get_radius"):
            continue
        var boss_radius: float = boss.call("get_radius")
        if candidate.distance_to((boss as Node2D).global_position) < gear_radius + boss_radius:
            return false
    for pillar in get_tree().get_nodes_in_group("pillar"):
        var p := pillar as Pillar
        if candidate.distance_to(p.global_position) < gear_radius + p.radius:
            return false
    var car := get_tree().get_first_node_in_group("car") as Car
    if car && candidate.distance_to(car.global_position) < gear_radius + car.get_bounding_radius():
        return false
    for cannon in get_tree().get_nodes_in_group("cannon"):
        var c := cannon as Cannon
        if candidate.distance_to(c.global_position) < gear_radius + c.get_radius():
            return false
    for hazard in get_tree().get_nodes_in_group("hazard"):
        var h := hazard as Hazard
        if candidate.distance_to(h.global_position) < gear_radius + h.get_radius():
            return false
    for gear in get_tree().get_nodes_in_group("gear"):
        var g := gear as Collectible
        if candidate.distance_to(g.global_position) < gear_radius + g.get_radius():
            return false
    for entry in _pending_gears:
        if candidate.distance_to(entry["position"]) < gear_radius + entry["radius"]:
            return false
    return true
