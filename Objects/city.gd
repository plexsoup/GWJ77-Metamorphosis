extends Node2D

var planet

var humans = 0
var max_humans = 5
var l_trees = 0
var max_l_trees = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_l_tree()





func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("trees"):
		area.get_parent().queue_free()


func spawn_human():
	var new_human = preload("res://Objects/human.tscn").instantiate()
	new_human.planet = planet
	add_child(new_human)
	new_human.position = (Vector2.RIGHT * planet.get_radius())
	humans += 1

func spawn_l_tree():
	var new_tree = preload("res://Objects/l_tree.tscn").instantiate()
	add_child(new_tree)
	new_tree.position = (Vector2.RIGHT * (planet.get_radius() + 180))
	l_trees += 1

func _on_spawn_timer_timeout() -> void:
	if humans < max_humans:
		if randf() < 0.2:
			spawn_human()
	elif l_trees < max_l_trees:
		if randf() < 0.1:
			spawn_l_tree()
	else:
		$SpawnTimer.stop()
