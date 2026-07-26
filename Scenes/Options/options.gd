class_name Options extends CanvasLayer

const LEVEL_COUNT := 15

var original_paused_state = false
var _suppressed: Dictionary = {}
var _level_buttons: Array[TextureButton] = []

@onready var _level_select: Control = $LevelSelect
@onready var _auto_crank_button: TextureButton = $LevelSelect/AutoCrankButton
@onready var _check_mark: TextureRect = $LevelSelect/AutoCrankButton/CheckMark


func _ready() -> void:
    for level_number in range(1, LEVEL_COUNT + 1):
        var button := _level_select.get_node("Level%d" % level_number) as TextureButton
        _level_buttons.append(button)
        button.pressed.connect(_on_level_pressed.bind(level_number))
    _auto_crank_button.pressed.connect(_on_auto_crank_pressed)


func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("options"):
        visible = !visible
        if visible:
            _refresh()
            original_paused_state = get_tree().paused
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
            get_tree().paused = true
            _suppress_always_nodes()
        else:
            _restore_always_nodes()
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
            get_tree().paused = original_paused_state


func _refresh() -> void:
    for i in range(_level_buttons.size()):
        _level_buttons[i].visible = GameState.is_completed(i + 1)
    _check_mark.visible = GameState.auto_crank_enabled


func _on_level_pressed(level_number: int) -> void:
    _restore_always_nodes()
    visible = false
    get_tree().paused = false
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    SceneTransition.transition_to_scene("res://Scenes/Levels/Level%d/Level.tscn" % level_number)


func _on_auto_crank_pressed() -> void:
    GameState.set_auto_crank(!GameState.auto_crank_enabled)
    _check_mark.visible = GameState.auto_crank_enabled


func _suppress_always_nodes() -> void:
    _suppressed.clear()
    if !get_tree().current_scene:
        return
    for node in get_tree().current_scene.find_children("*", "", true, false):
        if node == self || node.is_in_group("menu_pause_exempt"):
            continue
        if node.process_mode == Node.PROCESS_MODE_ALWAYS:
            _suppressed[node] = node.process_mode
            node.process_mode = Node.PROCESS_MODE_PAUSABLE


func _restore_always_nodes() -> void:
    for node in _suppressed:
        if is_instance_valid(node):
            node.process_mode = _suppressed[node]
    _suppressed.clear()
