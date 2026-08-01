class_name SteeringButtons extends Control

static var instance: SteeringButtons

@onready var _left: Control = $HBoxContainer/Left
@onready var _right: Control = $HBoxContainer/Right

var _touch_sides: Dictionary = {}


func _ready() -> void:
	instance = self
	var mobile := Constants.is_mobile_input()
	visible = mobile
	set_process_input(mobile)


func _exit_tree() -> void:
	if instance == self:
		instance = null
	_touch_sides.clear()
	_apply_action(&"left", false)
	_apply_action(&"right", false)


func is_point_on_buttons(pos: Vector2) -> bool:
	return !_side_at(pos).is_empty()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			_update_touch(touch.index, touch.position)
		else:
			_release_touch(touch.index)
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if _touch_sides.has(drag.index):
			_update_touch(drag.index, drag.position)


func _update_touch(index: int, position: Vector2) -> void:
	var side := _side_at(position)
	if side.is_empty():
		_release_touch(index)
		return
	_touch_sides[index] = side
	_refresh_actions()


func _release_touch(index: int) -> void:
	if !_touch_sides.has(index):
		return
	_touch_sides.erase(index)
	_refresh_actions()


func _side_at(position: Vector2) -> String:
	if _left.get_global_rect().has_point(position):
		return "left"
	if _right.get_global_rect().has_point(position):
		return "right"
	return ""


func _refresh_actions() -> void:
	_apply_action(&"left", _touch_sides.values().has("left"))
	_apply_action(&"right", _touch_sides.values().has("right"))


func _apply_action(action: StringName, pressed: bool) -> void:
	if pressed == Input.is_action_pressed(action):
		return
	if pressed:
		Input.action_press(action)
	else:
		Input.action_release(action)
