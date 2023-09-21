extends "res://scripts/entity_base.gd"

@export var emission_delay: float = 1.0 # delay between waves in seconds.
@export var start_delay: float = -1.0 # delay before starting in seconds. instant if <= 0
@export var emission_count: int = 10 # number of entity emissions per wave. spread across 360°
@export var max_emissions: int = -1 # number of emissions after which the emitter destroys. -1 = infinite
@export var time_between_entities: float = -1.0 # time in-between single emissions within the wave. instant if <= 0
@export var entity_speed: float = 40.0 # speed of emitted entity

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
	# Destroy when completed
	if max_emissions >= 0 and _emitted_count >= max_emissions:
		queue_free()

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
func _emit(angle: float):
	print_debug("Emitting...")
	var speed = entity_speed
	var bullet_inst: RigidBody2D = BulletScene.instantiate()
	
	#angle += _emitted_count % emission_count
	
	var direction = _angle_to_vector(angle) * speed
	
	bullet_inst.position = Vector2(0,0)
	
	bullet_inst.linear_velocity = direction
	
	add_child(bullet_inst)
	_emitted_count += 1
	

# Emit on Timer tick
func _on_emission_timer_timeout():
	print_debug("Emission timer tick...")
	if time_between_entities <= 0:
		_emit_all()
	else:
		_emit_all_timed()

func _emit_all():
	for n in range(emission_count):

		var angle = _degree * (n+1)
		
		print_debug("Emitting entity number " + str(n) + " at " + str(angle) + "°")
		
		_emit(angle)

func _emit_all_timed():
	for n in range(emission_count):
		
		var angle = _degree * (n+1)
		
		if n == 0:
			#print_debug("Emitting entity number " + str(n) + " at " + str(angle) + "°")
			#_emit(angle)
			pass
		else:
			#print_debug("Emitting timed entity number " + str(n) + " at " + str(angle) + "°")
			var emit_timer: Timer = Timer.new()
			emit_timer.set_one_shot(true)
			emit_timer.set_wait_time(n * time_between_entities)
			emit_timer.timeout.connect(self._emit.bind(angle))
			add_child(emit_timer)
			emit_timer.start()
			
		
