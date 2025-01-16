extends Control

const levels = [
	preload("res://solar_system.tscn"),
	preload("res://solar_system_02.tscn"),
	preload("res://solar_system_03.tscn"),
	preload("res://solar_system_04.tscn"),
	preload("res://solar_system_final.tscn"),
]
var level_index = 0

func _init():
	Globals.current_level = self

func spawn_new_solar_system():
	level_index += 1
	level_index = level_index % levels.size()

	
	var player = Globals.current_player
	var old_solar_system = Globals.solar_system
	
	old_solar_system.remove_child(player)
	old_solar_system.queue_free()
	var new_solar_system = levels[level_index].instantiate()
	add_child(new_solar_system)
	new_solar_system.add_child(player)
	player.state = player.states.FLYING


func _on_new_planet_requested(location):
	Globals.solar_system.spawn_planet(location)
	
func _on_hyperspace_completed():
	spawn_new_solar_system()
