extends "res://falling_materials/falling_material.gd"

enum states { FALLING, IDLE, GERMINATED }
var state = states.FALLING
@export var tree_scene: PackedScene = preload("res://Objects/l_tree.tscn")

func germinate(planet):
	if state in [states.GERMINATED]:
		return
		
	state = states.GERMINATED
	# spawn an l-tree
	call_deferred("set_freeze_enabled", true)
	
	var new_tree = tree_scene.instantiate()
	
	planet.add_child(new_tree)
	var normal : Vector2 = global_position - planet.global_position
	var angle = normal.angle()
	new_tree.rotation = angle
	new_tree.global_position = global_position
	queue_free()
	
