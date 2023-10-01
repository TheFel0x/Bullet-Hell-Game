class_name Emitter2D
extends BaseEntity2D
## Emitter for Bullets.
##
## An Emitter for Bullets and possibly in the future also other Entities like other Emitters.

## Animted Sprite choise for Bullets and Emitters 
enum BulletSprite {
	NONE, ## No Sprite
	ROUND, ## Round Sprite
	POINTY, ## Pointy Sprite
	STAR ## Star Sprite
}

## Settings related to the Emitter itself
@export_category("Emitter Settings")
## The sprite that the Emitter itself uses.
@export var emitter_sprite: BulletSprite = BulletSprite.ROUND
## Delay between waves in seconds.
@export var emission_delay: float = 0.3
## Delay before starting the first wave in seconds.
## Instant if this value is equal or less than 0.0
@export var start_delay: float = -1.0
## Mirrors the Emitter.
@export var mirrored: bool = false

## Settings related to the positioning of emitted Entities
@export_category("Entity Count and Positioning")
## Number of emitted entities per wave.
## Entities of this number get spread either across 360.0° or whatever maximum angle was chosen with max_angle.
@export var emission_count: int = 20
## Full angle that the bullets are spread across. (180.0 would be a half circle)
@export var max_angle: float = 360.0
## Time in-between individual emissions within the wave.
## If the value is equal or less than 0.0 the entire wave will be spawned at once.
@export var time_between_entities: float = -1 
## Wave offset after ever wave.
## If this value is 5, all emissions will be offset by 20° after 4 waves.
@export var wave_degree_offset: float = 10.0
## Distance of the spawned entity away from the emitter.
## Spawn is directly on the emitter if the value is equal to 0.0.
## Can deal with negative offset.
@export var emission_distance: float = 0.0


## Settings related to the behavior of the emitted Entities
@export_category("Entity Behavior and Properties")
## Chosen Entity Sprite.
@export var entity_sprite: BulletSprite = BulletSprite.POINTY
@export var entity_speed: float = 160.0 # speed of emitted entity
@export var entity_radius: float = 5.0 # radius of spawned entity
@export var entity_start_delay: float = -1.0 # start delay for bullets
@export var synchronized_awake: bool = false # when entities spawn with delay, determines if they should awaken synchronized 

@export_category("Life Time and Stopping")
@export var max_emissions: int = -1 # number of emissions after which the emitter destroys. -1 = infinite
@export var emitted_life_time: float = 10.0 # life time of emitted in seconds, infinite if <= 0 (not recommended)

var _degree: float = 0.0 # angle in between emitted entities. is calculated from the emission_count variable
var _emitted_count: int = 0 # counts emitted entities
var _scheduled_count: int = 0 # counts time emitted entities
var _children_freed: int = 0 # counts despawned entities

# TODO: maybe there's a way to @export an interface. in that case any BaseEntity that implements specific methods could be emitted
# so something like		Bullet implements iShootable			in Bullet
# then 					@export var emitted_entity: iShootable	in this script
# followed by 			const BulletScene = ...?				also in this script
const BulletScene = preload("res://scenes/bullet_2d.tscn") 

# FIXME: this should be functionality of BaseEntity instead
## Returns a Sprite name String for a BulletSprite enum choice
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
	# Set animation
	var animation = _enum_to_animation(emitter_sprite) 
	$AnimatedSprite2D.animation = animation
	
	# Caluclate degrees between emitted entities
	if max_angle < 360.0:
		_degree = max_angle / (emission_count-1)
	else:
		_degree = max_angle / (emission_count)
	
	# Start immediately or after timer
	if start_delay > 0.0:
		$DelayedStartTimer.start(start_delay)
	else:
		start()

func _process(delta):
	pass

## Starts Emitter
func start():
	# Prevent initial start delay
	_on_emission_timer_timeout()
	# Start EmissionTimer
	$EmissionTimer.set_wait_time(emission_delay)
	$EmissionTimer.start()

## Starts Emitter after Timer timeout
func _on_delayed_start_timer_timeout():
	start()

## Convert an angle (°) to a Vector2
func _angle_to_vector(degrees) -> Vector2:
	var radians = degrees * (PI / 180.0)
	var x = cos(radians)
	var y = sin(radians)
	return Vector2(x, y).normalized()

## Emit an entity.
## angle: angle of the bullet
## sync: Unique wait time to make the bullet synchronize with a timed wave
func _emit(angle: float, sync: float):
	
	# Don't spawn bullets off screen
	if not $VisibleOnScreenNotifier2D.is_on_screen():
		_emitted_count += 1
		return
	
	var speed = entity_speed
	
	# Instantiate bullet
	var bullet_inst: Bullet2D = BulletScene.instantiate()
	
	# Set start delay + wave sync (may be 0)
	var start_delay = 0.0 if entity_start_delay <= 0.0 else entity_start_delay
	bullet_inst.start_delay = start_delay + sync
	
	# Set Life Time and Animation
	bullet_inst.life_time = emitted_life_time
	bullet_inst.set_animation(_enum_to_animation(entity_sprite) )
	
	# Set angle offset, determined by wave_degree_offset and the current wave
	var wave = (_emitted_count / emission_count)
	var offset = wave * (-1 * wave_degree_offset if mirrored else wave_degree_offset)
	angle += offset
	
	# Rotate by 90(?) degrees to make it easier to use in the editor
	angle -= 90 +180 # FIXME: good god why did I write it like that
	
	# Set direction
	var parent_degree = rotation * 180 / PI
	var direction = _angle_to_vector(angle + parent_degree) * speed
	bullet_inst.set_direction(direction)
	
	# Set Position, using global position
	# also uses the offset from the emitter determined by emission_distance
	bullet_inst.position = global_position + direction.normalized() * emission_distance
	
	# Set bullet size (radius)
	bullet_inst.set_radius(entity_radius)
	
	# FIXME: this doesn't work anymore, lol
	bullet_inst.tree_exited.connect(_notify_child_freed)
	
	# Add child to scene, not to self
	# Double get_parent() allows the emitter to be attached to a physics body or similar
	get_parent().get_parent().add_child(bullet_inst)
	
	# Rotate the bullet toward where its going
	bullet_inst.look_at(bullet_inst.position+direction)
	bullet_inst.rotate(PI/2)
	
	# Count how many bullets were emitted
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

## Emit all bullets without timing.
func _emit_all():
	# Wave spawn loop
	for n in range(emission_count):
		# Set angle
		var angle = _degree * (n)
		angle *= -1 if mirrored else 1
		# Emit
		_emit(angle, 0.0)

## Emit all bullets with timing.
## Bullets aren't all spawned at the same time, but can all start moving at the same time if synchronization is enabled.
func _emit_all_timed():
	# NOTE: instead of doing math,
	# perhaps the bullets should listen to a signal
	# that tells them to start or stop moving.
	# Potential problem: overlapping waves triggering each other
	
	# Calculations needed multiple times in case of synchronization
	
	# Delay between bullets; can't use negatives for calculation -> 0
	var bullet_delay: float = 0.0 if time_between_entities <= 0.0 else time_between_entities
	# Time at which the last bullet is spawned, Relative to when the first spawned bullet
	var total_time_per_wave: float = bullet_delay * emission_count 
	
	# Wave spawn loop
	for n in range(emission_count):
		# Prevent spawning more than maximum emissions
		if max_emissions >= 0 and _scheduled_count >= max_emissions or max_emissions >= 0 and _emitted_count >= max_emissions:
			return
		
		# Set angle
		var angle = _degree * (n)
		angle *= -1 if mirrored else 1
		
		# Calculate sync time, if needed.
		# Unique to each bullet in wave to make their start time align.
		var sync: float = 0.0
		if synchronized_awake:
			# Calculate the unique wait time of the bullet relative to the wave.
			sync = total_time_per_wave - (bullet_delay * n) 
		
		# First bullet in the wave requires no timer.
		if n == 0:
			_emit(angle, sync)
		else:
			var emit_timer: Timer = Timer.new()
			emit_timer.set_one_shot(true)
			emit_timer.set_wait_time(n * time_between_entities)
			emit_timer.timeout.connect(self._emit.bind(angle, sync))
			add_child(emit_timer)
			emit_timer.start()
		
		# Count how many bullets are scheduled to prevent spawning too many
		_scheduled_count += 1

# FIXME: this doesn't work anymore since the children aren't part of this tree anymore
func _notify_child_freed():
	_children_freed += 1

	if max_emissions > 0:
		if _children_freed >= max_emissions:
			queue_free()
