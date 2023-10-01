extends BaseEntity2D
class_name Emitter2D

enum BulletSprite {
	NONE,
	ROUND,
	POINTY,
	STAR
}

@export var emission_delay: float = 0.3 # delay between waves in seconds.
@export var start_delay: float = -1.0 # delay before starting in seconds. instant if <= 0
@export var emission_count: int = 20 # number of entity emissions per wave. spread across 360° (or the chosen max_angle)
@export var max_emissions: int = -1 # number of emissions after which the emitter destroys. -1 = infinite
@export var time_between_entities: float = -1 # time in-between single emissions within the wave. instant if <= 0
@export var entity_speed: float = 160.0 # speed of emitted entity
@export var wave_degree_offset: float = 10.0 # degree offset after every wave
@export var mirrored: bool = false
@export var emitted_life_time: float = 10.0 # life time of emitted in seconds, infinite if <= 0 (not recommended)
@export var max_angle: float = 360.0 # full angle that the bullets are spread over (180.0 is a half circle)
@export var emission_distance: float = 0.0 # distance of the spawned entity, away from the source. on source if = 0.0
@export var entity_radius: float = 5.0 # radius of spawned entity
@export var emitter_sprite: BulletSprite = BulletSprite.ROUND # own sprite
@export var entity_sprite: BulletSprite = BulletSprite.POINTY # entity sprite
@export var entity_start_delay: float = -1.0 # start delay for bullets
@export var synchronized_awake: bool = false # when entities spawn with delay, determines if they should awaken synchronized 

var _degree: float = 0.0 # angle in between emitted entities. is calculated from the emission_count variable
var _emitted_count: int = 0 # counts emitted entities
var _scheduled_count: int = 0 # counts time emitted entities
var _children_freed: int = 0 # counts despawned entities

const BulletScene = preload("res://scenes/bullet_2d.tscn")

func _enum_to_animation(selected: BulletSprite) -> String:
	if selected == BulletSprite.NONE:
		return "none"
	elif selected == BulletSprite.STAR:
		return "star"
	elif selected == BulletSprite.ROUND:
		return "round"
	elif selected == BulletSprite.POINTY:
		return "pointy"
	else:
		return "error"

func _ready():
	
	var animation = _enum_to_animation(emitter_sprite) 
	$AnimatedSprite2D.animation = animation
	
	# Caluclate degrees between emitted entities
	if max_angle < 360.0:
		_degree = max_angle / (emission_count-1)
	else:
		_degree = max_angle / (emission_count)
	#print_debug("Emitter created...")
	if start_delay > 0.0:
		$DelayedStartTimer.start(start_delay)
	else:
		start()

func _process(delta):
	pass

func start():
	# don't have an initial start delay
	_on_emission_timer_timeout()
	
	$EmissionTimer.set_wait_time(emission_delay)
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
func _emit(angle: float, sync: float):
	
	# Don't spawn bullets off screen
	if not $VisibleOnScreenNotifier2D.is_on_screen():
		_emitted_count += 1
		return
	
	#print_debug("Emitting... SCHEDULED "+str(_scheduled_count)+" EMITTED "+str(_emitted_count))
	var speed = entity_speed
	var bullet_inst: Bullet2D = BulletScene.instantiate()
	
	# Set start delay + wave sync (may be 0)
	bullet_inst.start_delay = entity_start_delay + sync
	
	bullet_inst.life_time = emitted_life_time
	bullet_inst.set_animation(_enum_to_animation(entity_sprite) )
	
	var new_offset = (_emitted_count / emission_count)
	new_offset *= -1 * wave_degree_offset if mirrored else wave_degree_offset
	angle +=  new_offset
	
	angle -= 90 +180
	var parent_degree = rotation * 180 / PI
	var direction = _angle_to_vector(angle + parent_degree) * speed
	
	# Global position with emission distance
	bullet_inst.position = global_position + direction.normalized() * emission_distance
	
	bullet_inst.set_direction(direction)
	bullet_inst.set_radius(entity_radius)
	bullet_inst.tree_exited.connect(_notify_child_freed)
	
	# Add child to scene, not to self
	# Double get_parent() allows the emitter to be attached to a physics body or similar
	get_parent().get_parent().add_child(bullet_inst)
	# TESTING rotating the bullet toward where its going
	bullet_inst.look_at(bullet_inst.position+direction)
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

		var angle = _degree * (n)
		angle *= -1 if mirrored else 1
		
		#print_debug("Emitting entity number " + str(n) + " at " + str(angle) + "°")
		
		_emit(angle, 0.0)

func _emit_all_timed():
	
	# TODO: instead of doing math, perhaps the bullets should listen to a signal that tells them to start or stop moving.
	
	# time between bullets
	var bullet_delay: float = 0.0 if time_between_entities <= 0.0 else time_between_entities
	
	# Awake upon last bullet in wave if <= 0.0, else at wait time 
	var awake_delay: float = 0.0 if entity_start_delay <= 0.0 else entity_start_delay
	
	# time at which the last bullet is spawned, relative to the first spawned bullet
	var total_time_per_wave: float = bullet_delay * emission_count 
	
	for n in range(emission_count):
		
		if max_emissions >= 0 and _scheduled_count >= max_emissions or max_emissions >= 0 and _emitted_count >= max_emissions:
			return
		
		var angle = _degree * (n)
		angle *= -1 if mirrored else 1
		
		# calc synchronized awake time, unique to each bullet
		var sync: float = 0.0
		
		# calc if needed
		if synchronized_awake:
			sync = total_time_per_wave - (bullet_delay * n) # Calculate the unique wait time of the bullet relative to the wave
		
		if n == 0:
			#print_debug("TIMED Emitting entity number " + str(n) + " at " + str(angle) + "°")
			_emit(angle, sync)
		else:
			var emit_timer: Timer = Timer.new()
			emit_timer.set_one_shot(true)
			emit_timer.set_wait_time(n * time_between_entities)
			emit_timer.timeout.connect(self._emit.bind(angle, sync))
			add_child(emit_timer)
			emit_timer.start()
		
		print_debug("Scheduled Bullet "+str(n)+" at "+str(angle)+"° and "+str(sync)+"s sync")
		_scheduled_count += 1

# FIXME this doesn't work anymore since the children aren't part of this tree
func _notify_child_freed():
	_children_freed += 1

	if max_emissions > 0:
		if _children_freed >= max_emissions:
			queue_free()
