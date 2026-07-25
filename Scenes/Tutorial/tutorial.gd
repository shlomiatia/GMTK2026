class_name Tutorial extends CanvasLayer

static var _shown: bool = false

@onready var _message_label: Label = $MessageLabel

var _car: Car
var _crank: Crank
var _cycle_completed: bool = false


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
    _show_message("To get started, hold down the left mouse button")


func _show_message(text: String) -> void:
    _message_label.text = text
    _message_label.visible = true


func _on_crank_pressed() -> void:
    _show_message("Keeping your finger on the button,\nmove the mouse in a circular motion to wind it up.")


func _on_cycle_completed() -> void:
    _cycle_completed = true
    _show_message("Release to launch!")


func _on_crank_released(_degrees: float) -> void:
    if !_cycle_completed:
        _show_message("Hold left mouse button to start!")
        return
    _car.process_mode = Node.PROCESS_MODE_INHERIT
    get_tree().paused = false
    queue_free()
