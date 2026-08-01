class_name Car extends CharacterBody2D

signal launched
signal died
signal enemy_killed(enemy: Enemy)
signal cannon_killed(cannon: Cannon)
signal boss_hit(boss: Node)

enum State {IDLE, LAUNCHED, DEAD}

const _wall_collision_sfx := [
	preload("res://Audio/SFX V1/Wall collision-001.wav"),
	preload("res://Audio/SFX V1/Wall collision-002.wav"),
]
const _enemy_collision_sfx := preload("res://Audio/SFX V1/Enemy Collision.wav")

@onready var _collision_shape: CollisionShape2D = $CollisionShape2D
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _crank: Crank = $Car/Crank
@onready var _sprite: Sprite2D = $Car
@onready var _audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var _attack: Sprite2D = $Car/Attack
@onready var _smoke: SmokeParticleEmitter = $SmokeParticleEmitter

var _state: State = State.IDLE
var _wall_sfx_index: int = 0
var _attack_tween: Tween


func _ready() -> void:
	_animation_player.animation_finished.connect(_on_animation_finished)
	_crank.launched.connect(_on_crank_launched)


func _process(_delta: float) -> void:
	if _state == State.DEAD:
		return
	var speed := velocity.length() if _state == State.LAUNCHED else _crank.get_launch_speed()
	_sprite.self_modulate = MathUtils.speed_to_lethal_color(speed)
	_smoke.emitting = _state == State.LAUNCHED && velocity.length() > Constants.enemy_kill_speed


func _get_steer_delta(delta: float) -> float:
	return deg_to_rad(Constants.steer_speed) * Input.get_axis("left", "right") * delta


func _physics_process(delta: float) -> void:
	if _state == State.IDLE:
		rotation += _get_steer_delta(delta)
		return
	if _state != State.LAUNCHED:
		return
	var steer_angle := _get_steer_delta(delta)
	if steer_angle != 0.0:
		rotation += steer_angle
		velocity = velocity.rotated(steer_angle)
	velocity = velocity.move_toward(Vector2.ZERO, Constants.friction * delta)
	_handle_collision(move_and_collide(velocity * delta))

	if velocity.length() < Constants.enemy_kill_speed:
		_crank.set_enabled(true)
	if velocity.length() == 0.0:
		_state = State.IDLE


func _handle_collision(collision: KinematicCollision2D) -> void:
	if !collision:
		return
	_show_attack(-collision.get_normal())
	var sfx: AudioStream = null
	var boss_hit_registered := false
	var enemy := collision.get_collider() as Enemy
	if enemy && velocity.length() >= Constants.enemy_kill_speed:
		enemy.die()
		enemy_killed.emit(enemy)
		sfx = _enemy_collision_sfx
	var cannon := collision.get_collider().get_parent() as Cannon
	if cannon && velocity.length() >= Constants.enemy_kill_speed:
		cannon.die()
		cannon_killed.emit(cannon)
		sfx = _enemy_collision_sfx
	var collider: Node = collision.get_collider()
	var boss: Node = collider if collider.is_in_group("boss") else collider.get_parent()
	if boss && boss.is_in_group("boss") && velocity.length() >= Constants.enemy_kill_speed && boss.call("hit"):
		boss_hit.emit(boss)
		boss_hit_registered = true
		if !boss.call("is_dead"):
			SfxPlayer.play_boss_collision()
	if !sfx && !boss_hit_registered:
		sfx = _wall_collision_sfx[_wall_sfx_index]
		_wall_sfx_index = 1 - _wall_sfx_index
	if sfx:
		_audio_stream_player.stream = sfx
		_audio_stream_player.play()
	velocity = velocity.bounce(collision.get_normal()) * 0.75


func _show_attack(direction: Vector2) -> void:
	if _attack_tween:
		_attack_tween.kill()
	_attack.global_rotation = Vector2.DOWN.angle_to(direction)
	_attack.modulate = Color(1, 1, 1, 1)
	_attack_tween = create_tween()
	_attack_tween.tween_property(_attack, "modulate:a", 0.0, 0.25)


func _on_crank_launched(power_ratio: float) -> void:
	if _state == State.DEAD:
		return
	if _state == State.LAUNCHED && velocity.length() >= Constants.enemy_kill_speed:
		return
	_state = State.LAUNCHED
	_crank.set_enabled(false)
	velocity = - transform.y * power_ratio * Constants.max_speed
	launched.emit()


func push(motion: Vector2) -> void:
	if _state == State.DEAD:
		return
	move_and_collide(motion)


func get_bounding_radius() -> float:
	return (_collision_shape.shape as CapsuleShape2D).height / 2.0


func die() -> void:
	if _state == State.DEAD:
		return
	_state = State.DEAD
	_crank.set_enabled(false)
	_smoke.emitting = false
	velocity = Vector2.ZERO
	_animation_player.play("die")


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "die":
		died.emit()
