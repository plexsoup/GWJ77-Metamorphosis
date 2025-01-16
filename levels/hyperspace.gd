extends Node2D

signal completed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$StarTimer.start()
	$DurationTimer.start()
	completed.connect(Globals.current_level._on_hyperspace_completed)



func spawn_stars(num):
	for i in range(num):
		var new_star = preload("res://Objects/background_star.tscn").instantiate()
		add_child(new_star)
		new_star.position = Vector2.ONE.rotated(randf()*TAU) * randf()*256
		new_star.enter_hyperspace()
	
	
func _on_star_timer_timeout() -> void:
	spawn_stars(randi()%6+1)
	$StarTimer.set_wait_time(randf_range(0.05, 0.5))
	$StarTimer.start()


func _on_duration_timer_timeout() -> void:
	completed.emit()
