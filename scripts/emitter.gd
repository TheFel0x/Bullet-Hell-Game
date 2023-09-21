extends "res://scripts/entity_base.gd"

@export var emission_delay: float = 1.0 # delay between waves in seconds.
@export var start_delay: float = -1.0 # delay before starting in seconds. instant if <= 0
@export var emission_count: int = 5 # number of entity emissions per wave. spread across 360°
# TODO: variable that lets you choose how much time there is in-between individually emitted entities per wave (swirl pattern)

var _degree: float = 0.0 # angle in between emitted entities. is calculated from the emission_count variable

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

# Emit entity. TODO: Take entity type, life time
func _emit(angle: float, speed: float):
	print_debug("Emitting...")
	var bullet_inst: StaticBody2D = BulletScene.instantiate()
	var direction = Vector2.RIGHT.rotated(angle)
	
	bullet_inst.position = position
	bullet_inst.rotation = direction
	
	var velocity = Vector2(speed, 0.0)
	bullet_inst.linear_velocity = direction
	
	add_child(bullet_inst)

# Emit on Timer tick
func _on_emission_timer_timeout():
	print_debug("Emission timer tick...")
	for n in range(emission_count):
		var angle = _degree * n
		var speed = 40 # TODO: take this as input
		
		print_debug("Emitting entity number " + str(n) + " at " + str(angle) + "°")
		
		_emit(angle, speed)
