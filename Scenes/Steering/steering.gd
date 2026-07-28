class_name Steering extends Node

const _full_turn_angle := deg_to_rad(90.0)

@onready var _crank: Crank = get_tree().get_first_node_in_group("crank") as Crank


func get_axis(car_position: Vector2, car_forward: Vector2) -> float:
    if !Input.is_action_pressed("crank"):
        return 0.0
    var to_target := _crank.get_pointer_world_position() - car_position
    if to_target.length() < 1.0:
        return 0.0
    var error := car_forward.angle_to(to_target)
    return clampf(error / _full_turn_angle, -1.0, 1.0)
