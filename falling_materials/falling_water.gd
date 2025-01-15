extends falling_material


func _on_body_entered(body: Node) -> void:
	if body == null:
		return # what happened here? Why am I even getting this collision?

	if body.is_in_group("dirt") or body.is_in_group("planets"):
		var contact_index = 0
		for contact in contacts:
			if contact[0] == body:
				break
			contact_index += 1
		var collider = contacts[contact_index]
		spawn_lake(body, collider[1], collider[2])
		queue_free()


func spawn_lake(planet, location, normal): # global coords
	if not planet.has_node("Lakes"):
		var new_lake_folder = Node2D.new()
		new_lake_folder.name = "Lakes"
		planet.add_child(new_lake_folder)
		new_lake_folder.transform = planet.transform
	if is_near_lake(planet, location):
		return # don't spawn multiple lakes on top of each other
	var new_lake = preload("res://Objects/lake.tscn").instantiate()
	planet.get_node("Lakes").add_child(new_lake)
	var offset_distance = 76.0 * (planet.size / 256)
	var offset = location.direction_to(planet.global_position) * offset_distance
	new_lake.global_position = location + offset
	new_lake.global_rotation = normal.angle()
	if planet.get("size"):
		new_lake.scale = Vector2.ONE * (float(planet.size) / 256.0)
	
