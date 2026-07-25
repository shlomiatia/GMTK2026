extends Node

const _mute_db := -80.0

@onready var _level_player: AudioStreamPlayer = $LevelMusicPlayer
@onready var _boss_player: AudioStreamPlayer = $BossMusicPlayer

var boss_active: bool = false
var _fade_tween: Tween


func _ready() -> void:
    (_level_player.stream as AudioStreamMP3).loop = true
    (_boss_player.stream as AudioStreamMP3).loop = true
    _boss_player.volume_db = _mute_db
    _level_player.play()


func fade_out_level_music(duration: float) -> void:
    if _fade_tween:
        _fade_tween.kill()
    _fade_tween = create_tween()
    _fade_tween.tween_property(_level_player, "volume_db", _mute_db, duration)


func set_boss_level(is_boss: bool, fade_seconds: float) -> void:
    if is_boss == boss_active:
        return
    boss_active = is_boss
    if _fade_tween:
        _fade_tween.kill()
    _fade_tween = create_tween().set_parallel(true)
    if is_boss:
        _boss_player.volume_db = _mute_db
        _boss_player.play()
        _fade_tween.tween_property(_level_player, "volume_db", _mute_db, fade_seconds)
        _fade_tween.tween_property(_boss_player, "volume_db", 0.0, fade_seconds)
    else:
        _fade_tween.tween_property(_level_player, "volume_db", 0.0, fade_seconds)
        _fade_tween.tween_property(_boss_player, "volume_db", _mute_db, fade_seconds)
        _fade_tween.chain().tween_callback(_boss_player.stop)
