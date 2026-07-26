extends TextureButton

const _hover_scale := Vector2(1.05, 1.05)
const _press_scale := Vector2(0.95, 0.95)
const _tween_duration := 0.1

var _tween: Tween
var _image: Image


func _ready() -> void:
    mouse_entered.connect(_on_mouse_entered)
    mouse_exited.connect(_on_mouse_exited)
    button_down.connect(_on_button_down)
    button_up.connect(_on_button_up)
    if texture_normal:
        _image = texture_normal.get_image()


func _has_point(point: Vector2) -> bool:
    var pixel := Vector2i(point)
    if pixel.x < 0 || pixel.y < 0 || pixel.x >= size.x || pixel.y >= size.y:
        return false
    if !_image:
        return true
    return _image.get_pixelv(pixel).a > 0.1


func _on_mouse_entered() -> void:
    if !disabled:
        _animate_scale(_hover_scale)


func _on_mouse_exited() -> void:
    if !disabled:
        _animate_scale(Vector2.ONE)


func _on_button_down() -> void:
    _animate_scale(_press_scale)


func _on_button_up() -> void:
    _animate_scale(_hover_scale if is_hovered() else Vector2.ONE)


func _animate_scale(target: Vector2) -> void:
    if _tween:
        _tween.kill()
    _tween = create_tween()
    _tween.tween_property(self, "scale", target, _tween_duration)
