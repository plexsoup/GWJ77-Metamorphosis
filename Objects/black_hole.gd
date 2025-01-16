extends Area2D


func spawn_hyperspace_stars():
	$Sprite2D.hide()
	var new_hyperspace = preload("res://levels/hyperspace.tscn").instantiate()
	
	add_child(new_hyperspace) # should show up at my position, right?
	new_hyperspace.global_position = global_position

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.enter_hyperspace()
		spawn_hyperspace_stars()
	else: # destroy rigid bodies
		body.queue_free()
