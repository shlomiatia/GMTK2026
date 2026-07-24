class_name Car extends CharacterBody2D

signal launched
signal died
signal enemy_killed(enemy: Enemy)

enum State {IDLE, LAUNCHED, DEAD}

@onready var _collision_shape: CollisionShape2D = $CollisionShape2D
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _crank: Crank = $Car/Crank

var _state: State = State.IDLE
var _angular_velocity: float = 0.0


func _ready() -> void:
	_animation_player.animation_finished.connect(_on_animation_finished)
	_crank.launched.connect(_on_crank_launched)


func _physics_process(delta: float) -> void:
	if _state != State.LAUNCHED:
		return
	var dir := Input.get_axis("left", "right")
	_angular_velocity = deg_to_rad(Constants.steer_speed) * dir
	var steer_angle := _apply_angular_velocity(delta)
	if steer_angle != 0.0:
		velocity = velocity.rotated(steer_angle)
	velocity = velocity.move_toward(Vector2.ZERO, Constants.friction * delta)
	_handle_collision(move_and_collide(velocity * delta))

	if velocity.length() < Constants.rest_velocity_threshold:
		velocity = Vector2.ZERO
		_state = State.IDLE
		_angular_velocity = 0.0
		_crank.set_enabled(true)


func _handle_collision(collision: KinematicCollision2D) -> void:
	if !collision:
		return
	var enemy := collision.get_collider() as Enemy
	if enemy && velocity.length() >= Constants.enemy_kill_speed:
		enemy.die()
		enemy_killed.emit(enemy)
	velocity = velocity.bounce(collision.get_normal())


func _apply_angular_velocity(delta: float) -> float:
	var angle_delta := _angular_velocity * delta
	if angle_delta == 0.0:
		return 0.0
	var target_transform := Transform2D(rotation + angle_delta, global_position)
	if test_move(target_transform, Vector2.ZERO, null, 0.08, true):
		_angular_velocity = 0.0
		return 0.0
	rotation += angle_delta
	return angle_delta


func _on_crank_launched(power_ratio: float) -> void:
	if _state != State.IDLE:
		return
	_state = State.LAUNCHED
	_crank.set_enabled(false)
	velocity = - transform.y * power_ratio * Constants.max_speed
	launched.emit()


func get_bounding_radius() -> float:
	return (_collision_shape.shape as CapsuleShape2D).height / 2.0


func die() -> void:
	if _state == State.DEAD:
		return
	_state = State.DEAD
	_crank.set_enabled(false)
	velocity = Vector2.ZERO
	_animation_player.play("die")


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "die":
		died.emit()
