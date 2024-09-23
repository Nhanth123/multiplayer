extends CharacterBody2D

@export var player_camera: PackedScene
@export var player_sprite: AnimatedSprite2D
@export var camera_height = -378

@export var movement_speed = 300
@export var gravity = 30
@export var jump_strength = 600
@export var max_jumps = 1

@onready var initial_sprite_scale = player_sprite.scale

var jump_count = 0
var camera_instantiate
var owner_id = 1

var state = PlayerState.IDLE

enum PlayerState {
	IDLE,
	WALKING,
	JUMP_STARTED,
	JUMPING,
	DOUBLE_JUMPING,
	FALLING
}

func _enter_tree() -> void:
	owner_id = name.to_int()
	set_multiplayer_authority(owner_id)
	if owner_id != multiplayer.get_unique_id():
		return

	set_up_camera()

func _process(_delta: float) -> void:
	if multiplayer.multiplayer_peer == null:
		return
		
	if owner_id != multiplayer.get_unique_id():
		return
		
	update_camera_pos()

func _physics_process(_delta: float) -> void:
	if owner_id != multiplayer.get_unique_id():
		return

	var horizontal_input = (
		Input.get_action_strength("move_right") 
			- Input.get_action_strength("move_left"))
	
	velocity.x = horizontal_input * movement_speed
	velocity.y += gravity

	handle_movement_state()
	
	move_and_slide()

	face_movement_direction(horizontal_input)

func _on_animated_sprite_2d_animation_finished() -> void:
	if state == PlayerState.JUMPING:
		player_sprite.play("jump")

func set_up_camera():
	camera_instantiate = player_camera.instantiate()
	camera_instantiate.global_position.y = camera_height
	get_tree().current_scene.add_child.call_deferred(camera_instantiate)

func update_camera_pos():
	camera_instantiate.global_position.x = global_position.x

func face_movement_direction(horizontal_input):
	if not is_zero_approx(horizontal_input):
		if horizontal_input < 0:
			player_sprite.scale = Vector2(-initial_sprite_scale.x, initial_sprite_scale.y)
		else:
			player_sprite.scale = Vector2(initial_sprite_scale.x, initial_sprite_scale.y)

func handle_movement_state():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		state = PlayerState.JUMP_STARTED
	elif is_on_floor() and is_zero_approx(velocity.x):
		state = PlayerState.IDLE
	elif is_on_floor() and not is_zero_approx(velocity.x):
		state = PlayerState.WALKING
	else:
		state = PlayerState.JUMPING
		
	if velocity.y > 0.0 and not is_on_floor():
		if Input.is_action_just_pressed("jump"):
			state = PlayerState.DOUBLE_JUMPING
		else:
			state = PlayerState.FALLING
	
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y = 0.0
	
	# Process state
	match state:
		PlayerState.IDLE:
			player_sprite.play("idle")
			jump_count = 0
		PlayerState.WALKING:
			player_sprite.play("walk")
			jump_count = 0
		PlayerState.JUMP_STARTED:
			player_sprite.play("jump_start")
			jump_count += 1
			velocity.y = -jump_strength
		PlayerState.JUMPING:
			pass
		PlayerState.DOUBLE_JUMPING:
			player_sprite.play("double_jump_start")
			jump_strength += 1
			if jump_count <= max_jumps:
				velocity.y = -jump_strength
		PlayerState.FALLING:
			player_sprite.play("fall")

	#Player cancels jumping
	if Input.is_action_just_pressed("jump") and velocity.y < 0.0:
		velocity.y = 0.0
	
