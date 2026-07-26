extends Node2D

const _next_level_path := "res://Scenes/Levels/Level1/Level.tscn"

@onready var _start_button: TextureButton = $StartButton
@onready var _credits_button: TextureButton = $CreditsButton
@onready var _credits_overlay: Button = $CreditsOverlay
@onready var _credits_animation_player: AnimationPlayer = $CreditsOverlay/AnimationPlayer

var _credits_shown: bool = false


func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    _start_button.pressed.connect(_on_start_pressed)
    _credits_button.pressed.connect(_on_credits_pressed)


func _input(event: InputEvent) -> void:
    if !_credits_shown || !event.is_pressed() || event.is_echo():
        return
    if !(event is InputEventKey || event is InputEventMouseButton):
        return
    get_viewport().set_input_as_handled()
    _hide_credits()


func _on_start_pressed() -> void:
    _start_button.disabled = true
    _credits_button.disabled = true
    SceneTransition.transition_to_scene(_next_level_path)


func _on_credits_pressed() -> void:
    _start_button.disabled = true
    _credits_button.disabled = true
    _credits_overlay.visible = true
    _credits_animation_player.play("fade_in")
    await _credits_animation_player.animation_finished
    _credits_shown = true


func _hide_credits() -> void:
    _credits_shown = false
    _credits_animation_player.play("fade_out")
    await _credits_animation_player.animation_finished
    _credits_overlay.visible = false
    _start_button.disabled = false
    _credits_button.disabled = false
