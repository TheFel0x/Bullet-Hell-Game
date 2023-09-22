extends BaseEntity2D
class_name Bullet2D

var _direction: Vector2 = Vector2(0, 0)
var _radius: float = 5.0 # radius in px

func set_direction(direction: Vector2):
	_direction = direction

func set_radius(radius: float):
	_radius = radius

func set_animation(animation: String):
	$AnimatedSprite2D.stop()
	print_debug("Setting "+animation)
	$AnimatedSprite2D.animation = animation
	$AnimatedSprite2D.play(animation)
	print_debug("now playing "+$AnimatedSprite2D.animation)

func _ready():
	super()
	var shape = CircleShape2D.new()
	shape.radius = _radius
	$CollisionShape2D.set_shape(shape)
	# 1.25 Scale = 10px
	var calculated_scale: float = 1.25*(_radius*2) / 10
	$AnimatedSprite2D.apply_scale(Vector2(calculated_scale,calculated_scale))

func _process(delta):
	#print_debug("++++now playing "+$AnimatedSprite2D.animation)
	pass

func _physics_process(delta):
	var movement = _direction * delta
	position += movement
