extends "res://scripts/entity_base.gd"

var _direction: Vector2 = Vector2(0, 0)

func set_direction(direction: Vector2):
	_direction = direction

func _ready():
	pass

func _process(delta):
	pass

func _integrate_forces(delta):
	# go in a straight line
	linear_velocity = _direction
