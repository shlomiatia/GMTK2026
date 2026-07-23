class_name ShakingCamera extends Camera2D

var shake_strength: float = 0.0
var shake_decay: float = 0.1
var shake_intensity: float = 10.0

func _ready():
    shake_strength = 0.0

func _process(_delta: float):
    if shake_strength > 0:
        position = Vector2(
            randf_range(-shake_intensity, shake_intensity) * shake_strength,
            randf_range(-shake_intensity, shake_intensity) * shake_strength
        )
        shake_strength = lerp(shake_strength, 0.0, shake_decay)
    else:
        position = Vector2.ZERO

func start_screen_shake(strength: float = 1.0, intensity: float = 10.0, decay: float = 0.1):
    shake_strength = strength
    shake_intensity = intensity
    shake_decay = decay
