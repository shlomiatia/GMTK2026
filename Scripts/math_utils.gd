class_name MathUtils

static func aim_toward(current_rotation: float, to_target: Vector2, speed_degrees: float, delta: float) -> float:
    if to_target.length() <= 0.0:
        return current_rotation
    var target_rotation := to_target.angle() - PI / 2.0
    return rotate_toward(current_rotation, target_rotation, deg_to_rad(speed_degrees) * delta)


static func speed_to_lethal_color(speed: float) -> Color:
    var t := clampf((speed - Constants.enemy_kill_speed) / (Constants.max_speed - Constants.enemy_kill_speed), 0.0, 1.0)
    var amount := 0.0 if speed < Constants.enemy_kill_speed else lerpf(0.1, 1.0, t)
    return Color(1.0, 1.0 - amount, 1.0 - amount)


static func polygon_bounding_radius(polygon: PackedVector2Array) -> float:
    var radius := 0.0
    for point in polygon:
        radius = maxf(radius, point.length())
    return radius
