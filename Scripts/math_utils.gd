class_name MathUtils

static func aim_toward(current_rotation: float, to_target: Vector2, speed_degrees: float, delta: float) -> float:
    if to_target.length() <= 0.0:
        return current_rotation
    var target_rotation := to_target.angle() - PI / 2.0
    return rotate_toward(current_rotation, target_rotation, deg_to_rad(speed_degrees) * delta)
