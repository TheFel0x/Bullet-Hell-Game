extends "res://scripts/entity_base.gd"

@export var emission_delay: float = 4.2 # delay between waves in seconds.
@export var start_delay: float = -1.0 # delay before starting in seconds. instant if <= 0
@export var emission_count: int = 20 # number of entity emissions per wave. spread across 360°
@export var max_emissions: int = 40 # number of emissions after which the emitter destroys. -1 = infinite
@export var time_between_entities: float = 0.2 # time in-between single emissions within the wave. instant if <= 0
@export var entity_speed: float = 40.0 # speed of emitted entity

var _degree: float = 0.0 # angle in between emitted entities. is calculated from the emission_count variable
var _emitted_count: int = 0 # counts emitted entities
var _scheduled_count: int = 0 # counts time emitted entities

const BulletScene = preload("res://scenes/bullet.tscn")

func _ready():
	# Caluclate degrees between emitted entities
	_degree = 360.0 / emission_count
	print_debug("Emitter created...")
	if start_delay > 0.0:
		$DelayedStartTimer.start(start_delay)
	else:
		start()

func _process(delta):
	# Destroy when completed
	#if max_emissions >= 0 and _emitted_count >= max_emissions:
	#	queue_free()
	pass

func start():
	print_debug("Emitter started...")
	$EmissionTimer.set_wait_time(emission_delay)
	$EmissionTimer.timeout.connect(_on_emission_timer_timeout)
	$EmissionTimer.start()
	# don't have a start delay
	_on_emission_timer_timeout()

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
	print_debug("Emitting... SCHEDULED "+str(_scheduled_count)+" EMITTED "+str(_emitted_count))
	var speed = entity_speed
	var bullet_inst: RigidBody2D = BulletScene.instantiate()
	
	#angle += _emitted_count % emission_count
	
	var direction = _angle_to_vector(angle) * speed
	
	bullet_inst.position = Vector2(0,0)
	
	bullet_inst.set_direction(direction)
	
	add_child(bullet_inst)
	_emitted_count += 1
	

# Emit on Timer tick
func _on_emission_timer_timeout():
	if max_emissions >= 0 and _scheduled_count >= max_emissions or max_emissions >= 0 and _emitted_count >= max_emissions:
			return
	
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
		
		if max_emissions >= 0 and _scheduled_count >= max_emissions or max_emissions >= 0 and _emitted_count >= max_emissions:
			return
		
		var angle = _degree * (n+1)
		
		if n == 0:
			print_debug("TIMED Emitting entity number " + str(n) + " at " + str(angle) + "°")
			_emit(angle)
		else:
			print_debug("TIMED Emitting timed entity number " + str(n) + " at " + str(angle) + "°")
			var emit_timer: Timer = Timer.new()
			emit_timer.set_one_shot(true)
			emit_timer.set_wait_time(n * time_between_entities)
			emit_timer.timeout.connect(self._emit.bind(angle))
			add_child(emit_timer)
			emit_timer.start()
		
		_scheduled_count += 1

