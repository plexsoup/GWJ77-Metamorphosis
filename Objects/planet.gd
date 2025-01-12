## Planet

extends Node2D


var rotation_speed : float = 0.25

func _on_biosphere_body_entered(body: Node2D) -> void:
	if body.is_in_group("seeds"):
		# remove the seed and spawn a tree
		if body.has_method("germinate"):
			body.germinate(self)
	elif body.is_in_group("water"):
		spawn_lake(body.global_position)
		body.queue_free()

func spawn_lake(location):
	# TODO: figure this out.
	# options: 
	#	sprite splats
	# 	shader with list of blend locations
	# 	deformable terrain?
	var new_lake = preload("res://Objects/lake.tscn").instantiate()
	add_child(new_lake)
	var offset_distance = 76.0
	var offset = location.direction_to(global_position) * offset_distance
	new_lake.global_position = location + offset
	new_lake.rotation = (global_position-location).angle()
	
func _process(delta):
	$PlanetSprite.rotate(rotation_speed * delta)
