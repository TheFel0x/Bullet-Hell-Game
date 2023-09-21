extends AnimatableBody2D

@export var life_time: float = -1 # life time in seconds. infinite if < 0

func _ready():
	if life_time > 0:
		$LifeTimer.start(life_time)

func _process(delta):
	pass

# Delete on Screen Exited
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

# Life Time ended
func _on_life_timer_timeout():
	queue_free()
