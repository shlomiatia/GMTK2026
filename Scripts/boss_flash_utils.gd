class_name BossFlashUtils

const REVEAL_SECONDS := 0.1


static func flash(targets: Array, property: StringName, invincibility_duration: float) -> void:
    var host := targets[0] as CanvasItem
    var hold := maxf(invincibility_duration - REVEAL_SECONDS, 0.0)
    var property_path := NodePath(String(property))
    var tween := host.create_tween()
    tween.set_parallel(true)
    for target in targets:
        (target as CanvasItem).set(property, Color(1.0, 1.0, 1.0, 0.3))
        tween.tween_property(target, property_path, Color(1.0, 1.0, 1.0, 1.0), REVEAL_SECONDS).set_delay(hold)
