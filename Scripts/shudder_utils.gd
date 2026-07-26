class_name ShudderUtils

static func update(node: Node2D, base_position: Vector2, intensity: float) -> void:
    node.position = base_position + Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
