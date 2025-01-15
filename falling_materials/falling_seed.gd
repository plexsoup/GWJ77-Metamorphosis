extends falling_material

enum states { FALLING, IDLE, GERMINATED }
var state = states.FALLING


@export var tree_scene: PackedScene = preload("res://Objects/l_tree.tscn")

func germinate(planet, collision_point, collision_normal): # in global coords
	rotation = 0
	if state in [states.GERMINATED]:
		return
		
	state = states.GERMINATED
	# spawn an l-tree
	call_deferred("set_freeze_enabled", true)
	
	var new_tree = tree_scene.instantiate()
	new_tree.planet = planet
	
	planet.get_node("Trees").call_deferred("add_child", new_tree)
	await new_tree.ready

	new_tree.global_position = collision_point
	new_tree.global_rotation = collision_normal.angle()
	
	
	queue_free()
	




func _on_body_entered(body: Node) -> void:
	if body.is_in_group("dirt") or body.is_in_group("planets"):
		var colliding_dirt = get_colliding_bodies()[0]
		var collision_index = 0
		for contact in contacts:
			if contact[0] == colliding_dirt:
				break # break out of the loop
			collision_index += 1
		var collision_point = contacts[collision_index][1]
		var collision_normal = contacts[collision_index][2]
		germinate(body, collision_point, collision_normal)
