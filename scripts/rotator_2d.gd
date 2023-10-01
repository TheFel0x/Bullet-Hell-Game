class_name Rotator2D
extends Area2D

## Rotation Speed in RPM(?)
@export var speed: float = 1.0
## If Rotation is happening
@export var awake: bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	if not awake:
		return
	# FIXME: this is not RPM, I believe
	rotate(speed * delta)
