## A Homing Bullet is a bullet that can set a target.
## Upon awaking the direction is set to the targets location
## This only happens once upon wake-up
extends Bullet2D
class_name HomingBullet2D

# Defaults to the parent if there's no target (there should always be one!)
@export var _target: Area2D = get_parent()
@export var speed: int = 100

func set_target(target: Area2D):
	_target = target

func _find_direction():
	var dir_vec: Vector2 = Vector2(0,0)
	
	var point_A: Vector2 = get_global_position()
	var point_B: Vector2 = _target.get_global_position()
	
	dir_vec = point_B - point_A
	
	var unit_vec = dir_vec / dir_vec.length()
	
	return (unit_vec * speed)

func _awaken():
	# Set direction, then call the parent _awaken() function
	_direction = _find_direction()
	super()

# FIXME: this is for debugging only !!!!!!!!!!!
# !!!!!! this is for debugging only !!!!!!!!!!!
# !!!!!! this is for debugging only !!!!!!!!!!!
func _process(delta):
	set_animation("round")
	if not _awake:
		_awaken()
	super(delta)
