extends BaseEntity2D
class_name Emitter2D

@export var emission_delay: float = 0.3 # delay between waves in seconds.
@export var start_delay: float = -1.0 # delay before starting in seconds. instant if <= 0
@export var emission_count: int = 20 # number of entity emissions per wave. spread across 360°
@export var max_emissions: int = -1 # number of emissions after which the emitter destroys. -1 = infinite
@export var time_between_entities: float = -1 # time in-between single emissions within the wave. instant if <= 0
@export var entity_speed: float = 160.0 # speed of emitted entity
@export var wave_degree_offset: float = 10.0 # degree offset after every wave
@export var mirrored: bool = false
@export var emitted_life_time: float = 10.0 # life time of emitted in seconds, infinite if <= 0 (not recommended)

var _degree: float = 0.0 # angle in between emitted entities. is calculated from the emission_count variable
var _emitted_count: int = 0 # counts emitted entities
var _scheduled_count: int = 0 # counts time emitted entities
var _children_freed: int = 0 # counts despawned entities

const BulletScene = preload("res://scenes/bullet_2d.tscn")

func _ready():
	# Caluclate degrees between emitted entities
	_degree = 360.0 / emission_count
	#print_debug("Emitter created...")
	if start_delay > 0.0:
		$DelayedStartTimer.start(start_delay)
	else:
		start()

func _process(delta):
	pass

func start():
	#print_debug("Emitter started...")
	$EmissionTimer.set_wait_time(emission_delay)
	$EmissionTimer.start()
	# don't have a start delay
	_on_emission_timer_timeout()

# Delayed Start
func _on_delayed_start_timer_timeout():
	#print_debug("Emitter delay...")
	start()

func _angle_to_vector(degrees) -> Vector2:
	var radians = degrees * (PI / 180.0)
	var x = cos(radians)
	var y = sin(radians)
	return Vector2(x, y).normalized()

# Emit entity. TODO: life time, entity type
func _emit(angle: float):
	
	# Don't spawn bullets off screen
	if not $VisibleOnScreenNotifier2D.is_on_screen():
		_emitted_count += 1
		return
	
	#print_debug("Emitting... SCHEDULED "+str(_scheduled_count)+" EMITTED "+str(_emitted_count))
	var speed = entity_speed
	var bullet_inst: Bullet2D = BulletScene.instantiate()
	bullet_inst.life_time = emitted_life_time
	
	var new_offset = (_emitted_count / emission_count)
	new_offset *= -1 * wave_degree_offset if mirrored else wave_degree_offset
	angle +=  new_offset
	
	angle += 90
	var direction = _angle_to_vector(angle) * speed
	
	# Global position
	bullet_inst.position = global_position
	
	bullet_inst.set_direction(direction)
	bullet_inst.tree_exited.connect(_notify_child_freed)
	
	# Add child to scene, not to self
	# Double get_parent() allows the emitter to be attached to a physics body or similar
	get_parent().get_parent().add_child(bullet_inst)
	# TESTING rotating the bullet toward where its going
	bullet_inst.look_at(global_position+direction)
	bullet_inst.rotate(PI/2)
	_emitted_count += 1
	

# Emit on Timer tick
func _on_emission_timer_timeout():
	if max_emissions >= 0 and _scheduled_count >= max_emissions or max_emissions >= 0 and _emitted_count >= max_emissions:
			return
	
	#print_debug("Emission timer tick...")
	if time_between_entities <= 0:
		_emit_all()
	else:
		_emit_all_timed()

func _emit_all():
	for n in range(emission_count):

		var angle = _degree * (n+1)
		angle *= -1 if mirrored else 1
		
		#print_debug("Emitting entity number " + str(n) + " at " + str(angle) + "°")
		
		_emit(angle)

func _emit_all_timed():
	for n in range(emission_count):
		
		if max_emissions >= 0 and _scheduled_count >= max_emissions or max_emissions >= 0 and _emitted_count >= max_emissions:
			return
		
		var angle = _degree * (n+1)
		angle *= -1 if mirrored else 1
		
		if n == 0:
			#print_debug("TIMED Emitting entity number " + str(n) + " at " + str(angle) + "°")
			_emit(angle)
		else:
			#print_debug("TIMED Emitting timed entity number " + str(n) + " at " + str(angle) + "°")
			var emit_timer: Timer = Timer.new()
			emit_timer.set_one_shot(true)
			emit_timer.set_wait_time(n * time_between_entities)
			emit_timer.timeout.connect(self._emit.bind(angle))
			add_child(emit_timer)
			emit_timer.start()
		
		_scheduled_count += 1

func _notify_child_freed():
	_children_freed += 1

	if max_emissions > 0:
		if _children_freed >= max_emissions:
			queue_free()
