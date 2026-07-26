@tool
class_name SmokeParticleEmitter extends CPUParticles2D

@export var emission_rate: float = 15.0
@export var scale_target: float = 1.0


func _process(_delta: float) -> void:
	var target_amount := maxi(1, ceili(emission_rate * lifetime))
	if amount != target_amount:
		amount = target_amount
	if !scale_amount_curve || scale_amount_curve.point_count != 2 || !is_equal_approx(scale_amount_curve.get_point_position(1).y, scale_target):
		var curve := Curve.new()
		curve.add_point(Vector2(0.0, 1.0))
		curve.add_point(Vector2(1.0, scale_target))
		scale_amount_curve = curve
