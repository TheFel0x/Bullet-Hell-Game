extends "res://scripts/base_entity.gd"

var _direction: Vector2 = Vector2(0, 0)

func set_direction(direction: Vector2):
	_direction = direction

func _ready():
	pass

func _process(delta):
	pass

func _physics_process(delta):
	var movement = _direction * delta
	position += movement