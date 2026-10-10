# ----------------------------------------------------------------------------------- #
# ---------------------- 3D PLATFORMER CONTROLLER BY SD STUDIOS --------------------- #
# ---- Modified: Adventurer model, lives / damage / knockback / checkpoints / win --- #
# ----------------------------------------------------------------------------------- #

extends CharacterBody3D

# ---------- VARIABLES ---------- #

@export_category("Player Properties")
@export var move_speed : float = 6
@export var jump_force : float = 7
@export var follow_lerp_factor : float = 4
@export var jump_limit : int = 2

@export_group("Game Juice")
@export var jumpStretchSize := Vector3(0.8, 1.2, 0.8)

@export_group("Damage")
@export var knockback_force : float = 8.0
@export var invincible_time : float = 1.5

# Booleans
var is_grounded = false
var can_double_jump = false
var is_flipping = false
var is_hurt = false
var is_dead = false
var invincible = false
var controls_enabled = true

var knockback := Vector3.ZERO
var respawn_point := Vector3.ZERO
var flip_time := 0.0

# Onready Variables
@onready var model = $Model
@onready var animation : AnimationPlayer = $AnimationPlayer
@onready var spring_arm = %Gimbal

@onready var particle_trail = $ParticleTrail
@onready var footsteps = $Footsteps

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 2

# ---------- FUNCTIONS ---------- #

func _ready():
	respawn_point = global_position
	spring_arm.global_position = global_position
	animation.animation_finished.connect(_on_animation_finished)
	animation.play("Idle")

func _process(delta):
	player_animations()

	# Smoothly follow player's position
	spring_arm.global_position = spring_arm.global_position.lerp(global_position, delta * follow_lerp_factor)

	# Player Rotation (face the movement direction)
	if controls_enabled and is_moving():
		var look_direction = Vector2(velocity.z, velocity.x)
		model.rotation.y = lerp_angle(model.rotation.y, look_direction.angle(), delta * 12)

func _physics_process(delta):
	# Check if player is grounded or not
	is_grounded = is_on_floor()

	# Handle Jumping
	if is_grounded:
		can_double_jump = true
		if is_flipping and flip_time > 0.15:
			is_flipping = false

	if is_flipping:
		flip_time += delta

	if controls_enabled and Input.is_action_just_pressed("jump"):
		if is_on_floor():
			perform_jump()
		elif can_double_jump:
			perform_flip_jump()

	velocity.y -= gravity * delta
	get_input(delta)

func perform_jump():
	AudioManager.jump_sfx.pitch_scale = 1.12
	AudioManager.jump_sfx.play()

	jumpTween()
	animation.play("Jump", 0.1)
	velocity.y = jump_force

func perform_flip_jump():
	AudioManager.jump_sfx.pitch_scale = 0.8
	AudioManager.jump_sfx.play()
	can_double_jump = false
	is_flipping = true
	flip_time = 0.0
	animation.play("Flip", 0.05, 1.7)
	velocity.y = jump_force

func is_moving():
	return abs(velocity.z) > 0.05 || abs(velocity.x) > 0.05

func jumpTween():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", jumpStretchSize, 0.1)
	tween.tween_property(self, "scale", Vector3(1,1,1), 0.1)

# Get Player Input
func get_input(delta):
	var move_direction := Vector3.ZERO
	if controls_enabled:
		move_direction.x = Input.get_axis("move_left", "move_right")
		move_direction.z = Input.get_axis("move_forward", "move_back")

	# Move The player Towards Spring Arm/Camera Rotation
	move_direction = move_direction.rotated(Vector3.UP, spring_arm.rotation.y).normalized()
	velocity = Vector3(move_direction.x * move_speed, velocity.y, move_direction.z * move_speed)
	velocity += knockback
	knockback = knockback.move_toward(Vector3.ZERO, 18.0 * delta)

	move_and_slide()

# Handle Player Animations
func player_animations():
	particle_trail.emitting = false
	footsteps.stream_paused = true

	if is_dead or is_hurt or is_flipping or not controls_enabled:
		return

	if is_on_floor():
		if is_moving(): # Checks if player is moving
			animation.play("Run", 0.2)
			particle_trail.emitting = true
			footsteps.stream_paused = false
		else:
			animation.play("Idle", 0.3)
	else:
		animation.play("Jump", 0.2)

func _on_animation_finished(anim_name):
	if anim_name == "Hurt":
		is_hurt = false
	elif anim_name == "Flip":
		is_flipping = false

# ---------- DAMAGE / RESPAWN ---------- #

# Called by traps (Hazard.gd). source_position is used for the knockback direction.
func take_damage(source_position: Vector3):
	if invincible or is_dead or not controls_enabled:
		return
	var dir = global_position - source_position
	dir.y = 0
	if dir.length() < 0.05:
		dir = model.global_basis.z
	knockback = dir.normalized() * knockback_force
	velocity.y = jump_force * 0.6
	AudioManager.hurt_sfx.play()
	shake_camera()
	if GameManager.lose_life():
		die()
		return
	is_hurt = true
	is_flipping = false
	animation.play("Hurt", 0.05)
	start_invincibility()

# Called by DeadZone when the player falls off the world
func fell():
	if is_dead:
		return
	AudioManager.hurt_sfx.play()
	if GameManager.lose_life():
		die()
		return
	respawn()

func respawn():
	global_position = respawn_point
	velocity = Vector3.ZERO
	knockback = Vector3.ZERO
	spring_arm.global_position = global_position
	is_flipping = false
	is_hurt = false
	start_invincibility()

func die():
	is_dead = true
	controls_enabled = false
	knockback = Vector3.ZERO
	animation.play("Death", 0.1)
	AudioManager.gameover_sfx.play()
	await get_tree().create_timer(1.4).timeout
	GameManager.trigger_game_over()

func set_checkpoint(point: Vector3):
	respawn_point = point

func start_invincibility():
	invincible = true
	var blink := create_tween().set_loops(int(invincible_time / 0.15))
	blink.tween_callback(func(): model.visible = not model.visible).set_delay(0.15)
	await get_tree().create_timer(invincible_time).timeout
	blink.kill()
	model.visible = true
	invincible = false

func shake_camera():
	var cam : Camera3D = spring_arm.get_node("Camera3D")
	var t := create_tween()
	for i in 6:
		t.tween_property(cam, "h_offset", randf_range(-0.15, 0.15), 0.04)
		t.parallel().tween_property(cam, "v_offset", randf_range(-0.15, 0.15), 0.04)
	t.tween_property(cam, "h_offset", 0.0, 0.05)
	t.parallel().tween_property(cam, "v_offset", 0.0, 0.05)

# Reaching the door
func victory(look_at_point: Vector3):
	controls_enabled = false
	velocity = Vector3.ZERO
	knockback = Vector3.ZERO
	var to_cam = spring_arm.get_node("Camera3D").global_position - global_position
	model.rotation.y = Vector2(to_cam.z, to_cam.x).angle()
	animation.play("Victory", 0.2)
