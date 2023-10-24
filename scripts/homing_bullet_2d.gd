## A Homing Bullet is a bullet that can set a target.
## Upon awaking the direction is set to the targets location
## This only happens once upon wake-up
##
## It can have a "dumb" movement before activating homing
extends Bullet2D
class_name HomingBullet2D

# Defaults to the parent if there's no target (there should always be one!)
@export var _target: Area2D = get_parent()
@export var speed: int = 200

# Time to move in a straight line before homing in seconds
@export var dumb_move_time: float = 2.0
# Wait time before going into homing mode in seconds
@export var dumb_pause_time: float = 1.0

# Direction for non-homing movement
var rng = RandomNumberGenerator.new()
@export var dumb_direction: Vector2 = Vector2(rng.randi_range(0,50),rng.randi_range(0,50)) # FIXME: only rng there for making it look nice while testing

var _is_dumb: bool = false

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
	if not dumb_move_time <= 0.0:
		$DumbMoveTimer.wait_time = dumb_move_time
		_is_dumb = true
		$DumbMoveTimer.start()
	super()

func _get_smart():
	# Set direction, then call the parent _awaken() function
	_direction = _find_direction()
	_is_dumb = false

func _ready():
	
	_awaken() ## FIXME: THIS IS HERE FOR DEBUGGING
	set_animation("round") ## FIXME: THIS IS HERE FOR DEBUGGING
	
	super()

func _process(delta):
	super(delta)

func _physics_process(delta):
	if not _awake:
		return
	if _is_dumb:
		var movement = dumb_direction * delta
		position += movement
	else:
		var movement = _direction * delta
		position += movement


func _on_dumb_move_timer_timeout():
	if not dumb_pause_time <= 0.0:
		$DumbPauseTimer.wait_time = dumb_pause_time
		$DumbPauseTimer.start()
	else:
		_is_dumb = false
		_get_smart()


func _on_dumb_pause_timer_timeout():
	_is_dumb = false
	_get_smart()