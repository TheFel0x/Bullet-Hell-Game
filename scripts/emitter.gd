extends "res://scripts/entity_base.gd"

@export var emission_delay: float = 1.0 # delay between waves in seconds.
@export var start_delay: float = -1.0 # delay before starting in seconds. instant if <= 0
@export var emission_count: int = 10 # number of entity emissions per wave. spread across 360°
# TODO: variable that lets you choose how much time there is in-between individually emitted entities per wave (swirl pattern)

var _degree: float = 0.0 # angle in between emitted entities. is calculated from the emission_count variable
var _emitted_count: int = 0 # counts emitted entities

const BulletScene = preload("res://scenes/bullet.tscn")

func _ready():
	print_debug("Emitter created...")
	if start_delay > 0.0:
		$DelayedStartTimer.start(start_delay)
	else:
		start()
	# Caluclate degrees between emitted entities
	_degree = 360.0 / emission_count

func _process(delta):
	pass

func start():
	print_debug("Emitter started...")
	$EmissionTimer.start()

# Delayed Start
func _on_delayed_start_timer_timeout():
	print_debug("Emitter delay...")
	start()

func _angle_to_vector(degrees) -> Vector2:
	var radians = degrees * (PI / 180.0)
	var x = cos(radians)
	var y = sin(radians)
	return Vector2(x, y).normalized()


# Emit entity. TODO: life time, entity type
func _emit(angle: float, speed: float):
	print_debug("Emitting...")
	var bullet_inst: RigidBody2D = BulletScene.instantiate()
	
	angle += _emitted_count
	
	var direction = _angle_to_vector(angle) * speed
	
	bullet_inst.position = Vector2(0,0)
	
	bullet_inst.linear_velocity = direction
	
	add_child(bullet_inst)
	

# Emit on Timer tick
func _on_emission_timer_timeout():
	print_debug("Emission timer tick...")
	for n in range(emission_count):
		# DEBUG testing for fun
		
		var angle = _degree * (n+1)
		var speed = 80 # TODO: take this as input
		
		print_debug("Emitting entity number " + str(n) + " at " + str(angle) + "°")
		
		_emit(angle, speed)
	_emitted_count += 1
