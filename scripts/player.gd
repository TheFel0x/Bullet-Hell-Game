extends Area2D


const SPEED = 400.0
const PRECISION_SPEED = 200.0
var velocity: Vector2 = Vector2(0, 0)

# TODO: Maybe use some other type of bullet?
const BulletScene = preload("res://scenes/bullet_2d.tscn") 

func get_input():
	var precision_mode: bool = Input.is_action_pressed("precision")
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_direction
	velocity *= PRECISION_SPEED if precision_mode else SPEED
	
	# Handle Shooting input
	if Input.is_action_just_pressed("shoot"):
		# Initial shot has no delay ; FIXME: this potentially allows for spamming bullets
		_on_shoot_timer_timeout()
		$ShootTimer.start()
	if Input.is_action_just_released("shoot"):
		$ShootTimer.stop()
	
	if Input.is_action_just_pressed("bomb"):
		# TODO: implement boms
		print_debug("KA-BOOOOOM!")

func _physics_process(delta):
	get_input()
	position += velocity * delta

# Detect Hit and Items
func _on_area_entered(area):
	# Debug Prints
	if area.is_in_group("bullet_2d"):
		print_debug("It's a bullet!")
	elif area.is_in_group("emitter_2d"):
		print_debug("It's an emitter!")
	elif area.is_in_group("base_entity_2d"):
		print_debug("It's... some kind of entity.")
	else:
		var all_groups: String = ""
		for group in area.get_groups():
			all_groups += group + " "
		print_debug("Not sure what it is: ["+all_groups+"]")

func _on_shoot_timer_timeout():
	# Spawn Bullet
	var speed = 1000
	var direction: Vector2 = Vector2(0,-1) * speed
	var emission_distance: int = 20
	
	var bullet_inst: Bullet2D = BulletScene.instantiate()
	
	bullet_inst.set_direction(direction)
	bullet_inst.position = global_position + direction.normalized() * emission_distance
	# FIXME: use of magic string
	bullet_inst.set_animation("round")
	#bullet_inst.set_direction(Vector2(0,0))
	#bullet_inst.look_at()
	get_parent().get_parent().add_child(bullet_inst)
	# FIXME: another magic string :( ; also this doesn't do anything yet!
	bullet_inst.add_to_group('player_projectile')


