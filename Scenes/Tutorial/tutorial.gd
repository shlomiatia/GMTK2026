class_name Tutorial extends CanvasLayer

enum Mode {LEVEL1, SIMPLE}
enum FadeTrigger {ROTATE, ENEMY_DEFEATED}

const _HOLD_MESSAGE := "To get started, hold down the left mouse button.\nDon't let go until you're ready to launch."
const _WIND_UP_MESSAGE := "Wind up the mouse by making a circular motion.\nThe more you wind it up, the farther you'll go."
const _RELEASE_MESSAGE := "Release to launch!"
const _GO_MESSAGE := "Get to the stairs before time runs out!"

const _HOLD_MESSAGE_TOUCH := "To get started, hold your finger on the screen.\nDon't let go until you're ready to launch."
const _WIND_UP_MESSAGE_TOUCH := "Wind up by making a circular motion.\nThe more you wind it up, the farther you'll go."
const _RELEASE_MESSAGE_TOUCH := "Release to launch!"

@export var mode: Mode = Mode.LEVEL1
@export var simple_message: String = ""
@export var simple_message_touch: String = ""
@export var fade_trigger: FadeTrigger = FadeTrigger.ROTATE

@onready var _message_label: Label = $MarginContainer/MessageLabel

var _car: Car
var _crank: Crank
var _cycle_completed: bool = false
var _finished: bool = false
var _touch: bool = false


func _ready() -> void:
    _touch = Constants.is_mobile_input()
    _car = get_tree().get_first_node_in_group("car") as Car
    if mode == Mode.SIMPLE:
        if _touch && !simple_message_touch.is_empty():
            _show_message(simple_message_touch)
        else:
            _show_message(simple_message)
        if fade_trigger == FadeTrigger.ENEMY_DEFEATED:
            _car.enemy_killed.connect(_on_enemy_killed)
        set_process(fade_trigger == FadeTrigger.ROTATE)
        return
    _crank = get_tree().get_first_node_in_group("crank") as Crank
    _car.process_mode = Node.PROCESS_MODE_ALWAYS
    _crank.crank_pressed.connect(_on_crank_pressed)
    _crank.crank_released.connect(_on_crank_released)
    _crank.cycle_completed.connect(_on_cycle_completed)
    add_to_group("start_paused")
    get_tree().paused = true
    set_process(false)
    _show_message(_HOLD_MESSAGE_TOUCH if _touch else _HOLD_MESSAGE)


func _process(_delta: float) -> void:
    if fade_trigger != FadeTrigger.ROTATE:
        return
    if _touch && Input.is_action_just_pressed("crank"):
        _fade_out()
    elif Input.is_action_just_pressed("left") || Input.is_action_just_pressed("right"):
        _fade_out()


func _show_message(text: String) -> void:
    _message_label.text = text
    _message_label.visible = true


func _on_crank_pressed() -> void:
    if _finished:
        return
    _show_message(_WIND_UP_MESSAGE_TOUCH if _touch else _WIND_UP_MESSAGE)


func _on_cycle_completed() -> void:
    if _finished:
        return
    _cycle_completed = true
    _show_message(_RELEASE_MESSAGE_TOUCH if _touch else _RELEASE_MESSAGE)


func _on_crank_released(_degrees: float) -> void:
    if _finished:
        return
    if !_cycle_completed:
        _show_message(_HOLD_MESSAGE_TOUCH if _touch else _HOLD_MESSAGE)
        return
    _finished = true
    _car.process_mode = Node.PROCESS_MODE_INHERIT
    remove_from_group("start_paused")
    get_tree().paused = false
    _show_message(_GO_MESSAGE)


func _on_enemy_killed(_enemy: Enemy) -> void:
    _fade_out()


func _fade_out() -> void:
    if _finished:
        return
    _finished = true
    var tween := create_tween()
    tween.tween_property(_message_label, "modulate:a", 0.0, 0.4)
    tween.tween_callback(queue_free)
