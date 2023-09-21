extends Area2D


const SPEED = 400.0
const PRECISION_SPEED = 200.0
var velocity: Vector2 = Vector2(0, 0)

func get_input():
	var precision_mode: bool = Input.is_action_pressed("precision")
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_direction
	velocity *= PRECISION_SPEED if precision_mode else SPEED

func _physics_process(delta):
	get_input()
	position += velocity * delta

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
