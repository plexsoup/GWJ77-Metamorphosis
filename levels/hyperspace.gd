extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.start()




func spawn_stars(num):
	for i in range(num):
		var new_star = preload("res://Objects/background_star.tscn").instantiate()
		add_child(new_star)
		new_star.global_position = Globals.current_player.global_position + Vector2.ONE.rotated(randf()*TAU) * randf()*256
		new_star.enter_hyperspace()
	
	
func _on_timer_timeout() -> void:
	spawn_stars(randi()%6+1)
	$Timer.set_wait_time(randf_range(0.05, 0.5))
	$Timer.start()
