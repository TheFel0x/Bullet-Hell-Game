extends BaseEntity2D
class_name Bullet2D

var _direction: Vector2 = Vector2(0, 0)
var _radius: float = 5.0 # radius in px
@export var start_delay = -1.0 # start delay in seconds. none if <= 0.0
var _awake: bool = false # if the bullet should move 

func set_direction(direction: Vector2):
	_direction = direction

func set_radius(radius: float):
	_radius = radius

func set_animation(animation: String):
	$AnimatedSprite2D.stop()
	$AnimatedSprite2D.animation = animation
	$AnimatedSprite2D.play(animation)

func _ready():
	super()
	
	# Set shape
	var shape = CircleShape2D.new()
	shape.radius = _radius
	$CollisionShape2D.set_shape(shape)
	var calculated_scale: float = 1.25*(_radius*2) / 10
	$AnimatedSprite2D.apply_scale(Vector2(calculated_scale,calculated_scale))
	
	# Wake bullet up when needed
	if start_delay <= 0.0:
		_awaken()
	else:
		$StartDelayTimer.set_wait_time(start_delay)
		$StartDelayTimer.timeout.connect(self._awaken)
		$StartDelayTimer.start()

# FIXME: I'm sure this doesn't need to be a function, lol
func _awaken():
	_awake = true

func _process(_delta):
	pass

func _physics_process(delta):
	if not _awake:
		return
	var movement = _direction * delta
	position += movement
