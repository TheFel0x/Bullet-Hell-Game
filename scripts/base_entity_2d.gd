extends Area2D
class_name BaseEntity2D

@export var life_time: float = -1 # life time in seconds. infinite if < 0
@export var auto_vanish: bool = true # if it should vanish when leaving the screen

func _ready():
	if life_time > 0:
		$LifeTimer.set_wait_time(life_time)
		$LifeTimer.start()
	else:
		$LifeTimer.stop()

func _process(delta):
	pass

# Delete on Screen Exited
func _on_visible_on_screen_notifier_2d_screen_exited():
	if auto_vanish:
		queue_free()

# Life Time ended
func _on_life_timer_timeout():
	# FIXME: returning here just for testing PLEASE FIX THE LIFE TIME LATER
	return
	print_debug("LifeTimer ended. Timer was "+str(life_time))
	queue_free()
