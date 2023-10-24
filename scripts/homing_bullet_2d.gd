# TODO: make this work with the normal Emitter2D


## A Homing Bullet is a bullet that can set a target.
## Upon awaking the direction is set to the targets location
## This only happens once upon wake-up
##
## It can have a "dumb" movement before activating homing
extends Bullet2D
class_name HomingBullet2D

# Defaults to the parent if there's no target (there should always be one!)
@export var _target: Area2D
@export var speed: int = 200

# Time to move in a straight line before homing in seconds
@export var dumb_move_time: float = 2.0
# Wait time before going into homing mode in seconds
@export var dumb_pause_time: float = 1.0

# Direction for non-homing movement
var rng = RandomNumberGenerator.new()

var _is_dumb: bool = false

func set_homing_properties(d_move_time: float, d_pause_time: float, h_speed: int):
	print_debug("set")
	dumb_move_time = d_move_time
	dumb_pause_time = d_pause_time
	h_speed = speed

func set_target(target: Area2D):
	_target = target

func _find_direction():
	if _target == null:
		_target = get_tree().get_nodes_in_group("player")[0]
	
	var dir_vec: Vector2 = Vector2(0,0)
	
	var point_A: Vector2 = get_global_position()
	var point_B: Vector2 = _target.get_global_position()
	
	dir_vec = point_B - point_A
	
	var unit_vec = dir_vec / dir_vec.length()
	
	return (unit_vec * speed)

func _awaken():
	print_debug("move time: "+str(dumb_move_time))
	print_debug("pause time: "+str(dumb_pause_time))
	if not dumb_move_time <= 0.0:
		$DumbMoveTimer.wait_time = dumb_move_time
		_is_dumb = true
		$DumbMoveTimer.start()
	super()

func _get_smart():
	# Set direction, then call the parent _awaken() function
	_direction = _find_direction()
	_is_dumb = false
	look_at(position+_direction)
	rotate(PI/2)

func _ready():
	super()

func _process(delta):
	super(delta)

func _physics_process(delta):
	if not _awake:
		return
	var movement = _direction * delta
	position += movement


func _on_dumb_move_timer_timeout():
	if not dumb_pause_time <= 0.0:
		_direction = Vector2(0,0)
		$DumbPauseTimer.wait_time = dumb_pause_time
		$DumbPauseTimer.start()
	else:
		_is_dumb = false
		_get_smart()


func _on_dumb_pause_timer_timeout():
	_is_dumb = false
	_get_smart()
