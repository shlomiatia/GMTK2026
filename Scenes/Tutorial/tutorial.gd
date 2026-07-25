class_name Tutorial extends CanvasLayer

static var _shown: bool = false

@onready var _message_label: Label = $MarginContainer/MessageLabel

var _car: Car
var _crank: Crank
var _cycle_completed: bool = false
var _rotated: bool = false
var _launched: bool = false


func _ready() -> void:
    if _shown:
        queue_free()
        return
    _shown = true
    _car = get_tree().get_first_node_in_group("car") as Car
    _crank = get_tree().get_first_node_in_group("crank") as Crank
    _car.process_mode = Node.PROCESS_MODE_ALWAYS
    _crank.crank_pressed.connect(_on_crank_pressed)
    _crank.crank_released.connect(_on_crank_released)
    _crank.cycle_completed.connect(_on_cycle_completed)
    get_tree().paused = true
    _show_message("To get started, hold down the left mouse button.\nDon't let go until you're ready to launch.")


func _process(_delta: float) -> void:
    if _cycle_completed && !_rotated && (Input.is_action_just_pressed("left") || Input.is_action_just_pressed("right")):
        _rotated = true
        if _launched:
            _finish()
        else:
            _show_message("Release to launch!")


func _show_message(text: String) -> void:
    _message_label.text = text
    _message_label.visible = true


func _on_crank_pressed() -> void:
    _show_message("Wind up the mouse by making a circular motion.\nThe more you wind it up, the farther you'll go.")


func _on_cycle_completed() -> void:
    _cycle_completed = true
    _show_message("Don't forget to aim! Use A to turn left and D to turn right.")


func _on_crank_released(_degrees: float) -> void:
    if !_cycle_completed:
        _show_message("Hold left mouse button to start!")
        return
    _launched = true
    _car.process_mode = Node.PROCESS_MODE_INHERIT
    get_tree().paused = false
    if _rotated:
        _finish()


func _finish() -> void:
    _message_label.visible = false
    queue_free()
