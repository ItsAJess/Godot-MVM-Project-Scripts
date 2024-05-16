extends CharacterBody2D

@export var movement_data : PlayerMovementData

@onready var player_sheets = $PlayerSheets
@onready var player_anim = $PlayerAnim
@onready var attack_area_2d = $AttackArea2D
@onready var starting_position = global_position

var can_dash = true
var can_shriek = true
var can_coyote_jump = false
var can_coyote_wall_jump = false
var double_jump = false
var just_wall_jumped = false
var is_wall_sliding = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var was_wall_normal = Vector2.ZERO

var current_state = player_states.MOVE
enum player_states {MOVE, SWORD, SHRIEK, DEAD, DASH}

func _physics_process(delta):
	
	if player_data.life <= 0:
		current_state = player_states.DEAD
	
	var input_axis = Input.get_axis("ui_left", "ui_right")
	
	if Input.is_action_just_pressed("Sword"):
		current_state = player_states.SWORD
		
	if Input.is_action_just_pressed("Dash"):
		current_state = player_states.DASH
	
	if Input.is_action_just_pressed("Shriek"):
		current_state = player_states.SHRIEK
	
	var was_on_floor = is_on_floor()
	var was_on_wall = is_on_wall_only()
	
	if was_on_wall:
		was_wall_normal = get_wall_normal()
	match current_state:
		player_states.MOVE:
			$AttackArea2D/SwordArea.disabled = true
			$AttackArea2D/Shriek.disabled = true
			update_animations(input_axis)
			movement(input_axis, delta)
		player_states.DASH:
			dashing(input_axis)
			movement(input_axis, delta)
		player_states.SWORD:
			sword(input_axis, delta)
			movement(input_axis, delta)
		player_states.SHRIEK:
			shriek()
			movement(input_axis, delta)
		player_states.DEAD:
			dead(delta)
	
	
	
	var just_left_edge = was_on_floor and not is_on_floor() and velocity.y >= 0.0
	if just_left_edge:
		$FailTechTimer.start()
		can_coyote_jump = true
	
	var just_left_wall = was_on_wall and not is_on_wall()
	if just_left_wall:
		$FailTechTimer.start()
		can_coyote_wall_jump = true
		
	just_wall_jumped = false
	
func movement(input_axis, delta):
	
	handle_acceleration(input_axis, delta)
	handle_air_acceleration(input_axis, delta)
	apply_friction(input_axis, delta)
	apply_air_resistance(input_axis, delta)
	apply_gravity(delta)
	handle_wall_slide(delta)
	handle_wall_jump()
	handle_jump()
	move_and_slide()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * movement_data.gravity_scale * delta

func handle_wall_slide(delta):
	if is_on_wall() and !is_on_floor():
		if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
			is_wall_sliding = true
		else:
			is_wall_sliding = false
	else:
		is_wall_sliding = false
	
	if is_wall_sliding:
		velocity.y += (100 * delta)
		velocity.y = min(velocity.y, 100)

func handle_wall_jump():
	if not is_on_wall_only() and not can_coyote_wall_jump: return
	
	var wall_normal = get_wall_normal()
	
	if can_coyote_wall_jump:
		wall_normal = was_wall_normal
	
	if Input.is_action_just_pressed("ui_accept"):
		velocity.x = wall_normal.x * movement_data.speed * 1.5
		velocity.y = movement_data.jump_velocity 
		just_wall_jumped = true

func handle_jump():
	if is_on_floor(): double_jump = true
	
	if is_on_floor() or can_coyote_jump:
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = movement_data.jump_velocity
	elif not is_on_floor():
		if Input.is_action_just_released("ui_accept") and velocity.y < movement_data.jump_velocity / 2.0:
			velocity.y = movement_data.jump_velocity / 2.0
		
		if Input.is_action_just_pressed("ui_accept") and double_jump and not just_wall_jumped:
			velocity.y = movement_data.jump_velocity * 0.8
			double_jump = false

func handle_acceleration(input_axis, delta):
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.acceleration * delta)

func handle_air_acceleration(input_axis, delta):
	if is_on_floor(): return
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.air_acceleration * delta)

func apply_friction(input_axis, delta):
	if not is_on_floor(): return
	if input_axis == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.friction * delta)

func apply_air_resistance(input_axis, delta):
	if input_axis == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.air_resistance * delta)

func update_animations(input_axis):
	if input_axis != 0:
		player_sheets.flip_h = input_axis < 0
		attack_area_2d.position.x = 0
		if input_axis < 0:
			attack_area_2d.position.x = -26
		player_anim.play("Walk")
	else:
		player_anim.play("Idle")
	if not is_on_floor():
		if velocity.y < 0:
			player_anim.play("Jump")
		if velocity.y > 0:
			player_anim.play("Fall")

func sword(input, delta):
	player_anim.play("Sword")

func shriek():
	if can_shriek == true:
		if player_sheets.flip_h == false:
			player_anim.play("ShriekRight")
			await get_tree().create_timer(0.3).timeout
			can_shriek = false
		if player_sheets.flip_h == true:
			player_anim.play("ShriekLeft")
			await get_tree().create_timer(0.3).timeout
			can_shriek = false
		$ShriekTimer.start()
	else:
		current_state = player_states.MOVE

func dashing(input_axis):
	if can_dash == true:
		can_dash = false
		$DashTimer.start()
		if player_sheets.flip_h == false:
			velocity.x += 300
			await get_tree().create_timer(0.03).timeout
			current_state = player_states.MOVE
		if player_sheets.flip_h == true:
			velocity.x -= 300
			await get_tree().create_timer(0.03).timeout
			current_state = player_states.MOVE
	else:
		current_state = player_states.MOVE

func dead(delta):
	apply_gravity(delta)
	move_and_slide()
	
	player_anim.play("Dead")
	velocity.x = 0
	await player_anim.animation_finished
	player_data.life = 3
	player_data.coin = 0
	
	if get_tree():
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/world.tscn")
	
func reset_state():
	current_state = player_states.MOVE

func _on_dash_timer_timeout():
	can_dash = true

func _on_fail_tech_timer_timeout():
	can_coyote_jump = false
	can_coyote_wall_jump = false


func _on_shriek_timer_timeout():
	can_shriek = true
