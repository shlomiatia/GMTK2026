extends Node

const _win_stair_sfx := preload("res://Audio/SFX V1/Win Stair Collision.wav")
const _win_boss_sfx := preload("res://Audio/SFX V1/Win Boss Death.wav")
const _loss_sfx := preload("res://Audio/SFX V1/Loss.wav")
const _restart_sfx := preload("res://Audio/SFX V1/Restart.wav")
const _pause_sfx := preload("res://Audio/SFX V1/Pause.wav")
const _winder_click_sfx := preload("res://Audio/SFX V1/Winder Click.wav")
const _boss_collision_sfx := preload("res://Audio/SFX V1/Boss Collision NO KILL.wav")

@onready var _player: AudioStreamPlayer = $AudioStreamPlayer


func play_win_stair() -> void:
	_play(_win_stair_sfx)


func play_win_boss() -> void:
	_play(_win_boss_sfx)


func play_loss() -> void:
	_play(_loss_sfx)


func play_restart() -> void:
	_play(_restart_sfx)


func play_pause() -> void:
	_play(_pause_sfx)


func play_winder_click() -> void:
	_play(_winder_click_sfx)


func play_boss_collision() -> void:
	_play(_boss_collision_sfx)


func _play(stream: AudioStream) -> void:
	_player.stream = stream
	_player.play()
