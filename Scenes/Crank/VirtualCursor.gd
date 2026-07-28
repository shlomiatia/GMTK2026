class_name VirtualCursor extends Sprite2D

signal moved(relative: Vector2)

var _world_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    _world_pos = get_global_mouse_position()
    global_position = _world_pos

func _input(event: InputEvent) -> void:
    var motion_relative: Vector2
    if event is InputEventMouseMotion:
        motion_relative = (event as InputEventMouseMotion).relative
    elif event is InputEventScreenDrag:
        motion_relative = (event as InputEventScreenDrag).relative
    else:
        return
    var relative := get_viewport().get_canvas_transform().affine_inverse().basis_xform(motion_relative) * Constants.virtual_cursor_sensitivity
    _world_pos += relative
    _clamp_to_viewport()
    global_position = _world_pos
    moved.emit(relative)

func _clamp_to_viewport() -> void:
    var target_transform := get_viewport().get_canvas_transform().affine_inverse()
    var visible_rect := get_viewport().get_visible_rect()
    var corner_a := target_transform * visible_rect.position
    var corner_b := target_transform * visible_rect.end
    _world_pos.x = clampf(_world_pos.x, minf(corner_a.x, corner_b.x), maxf(corner_a.x, corner_b.x))
    _world_pos.y = clampf(_world_pos.y, minf(corner_a.y, corner_b.y), maxf(corner_a.y, corner_b.y))
