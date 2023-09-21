extends Area2D

@export var normal_speed: int = 400 # (pixels/sec).
@export var precision_speed: int = 200 # (pixels/sec).
var screen_size: Vector2

func _ready():
	screen_size = get_viewport_rect().size

func _process(delta):
	_handle_input(delta)

func _handle_input(delta: float):
	var velocity: Vector2 = Vector2.ZERO
	var precision_mode: bool = false
	
	# Check Precision Mode
	if Input.is_action_pressed("precision"):
		precision_mode = true
	
	# Check Movement
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	
	# Set Velocity
	if velocity.length() > 0:
		velocity = velocity.normalized()
		velocity *= precision_speed if precision_mode else normal_speed
	
	# Update Position
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

# Detect Hit and Items
func _on_body_entered(body):
	# Debug Prints
	if body.is_in_group("bullet"):
		print_debug("It's a bullet!")
	elif body.is_in_group("emitter"):
		print_debug("It's an emitter!")
	else:
		var all_groups: String = ""
		for group in body.get_groups():
			all_groups += group + " "
		print_debug("Not sure what it is: ["+all_groups+"]")
