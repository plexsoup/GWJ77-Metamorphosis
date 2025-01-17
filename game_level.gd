extends Control

const levels = [
	preload("res://solar_system_01.tscn"),
	preload("res://solar_system_02.tscn"),
	preload("res://solar_system_03.tscn"),
	preload("res://solar_system_04.tscn"),
	preload("res://solar_system_final.tscn"),
]
var level_index = -1

var trees_grown : int = 0
var planets_spawned : int = 0
var atmospheres_created : int = 0
var aliens_destroyed : int = 0
var civilizations_built : int = 0


func _init():
	Globals.current_level = self

func _ready():
	spawn_new_solar_system()

func spawn_hyperspace():
# go to next level.
	var player = Globals.current_player
	var player_pos : Vector2 = Vector2.ZERO
	if player and is_instance_valid(player):
		player_pos = player.global_position
		player.enter_hyperspace()
		
	var hyperspace = preload("res://levels/hyperspace.tscn").instantiate()
	Globals.current_solar_system.add_child(hyperspace)
	hyperspace.global_position = player_pos
	
	


func spawn_new_solar_system():
	reset_win_conditions()
	level_index += 1
	level_index = level_index % levels.size()
	
	var old_solar_system = Globals.current_solar_system
	if old_solar_system:
		old_solar_system.queue_free()
	var new_solar_system = levels[level_index].instantiate()
	add_child(new_solar_system)
	new_solar_system.set_deferred("name", "SolarSystem")
	create_goal_hint(new_solar_system)


		
func create_goal_hint(system):
	var object_name = Globals.goals.keys()[system.goal]
	var verb = ""
	var remaining = system.goal_quantity
	match system.goal:
		Globals.goals.trees:
			verb = "Grow"
			remaining -= trees_grown
		Globals.goals.planets:
			verb = "Create"
			remaining -= planets_spawned
		Globals.goals.atmospheres:
			verb = "Establish"
			remaining -= atmospheres_created
		Globals.goals.civilizations:
			verb = "Cultivate"
			remaining -= civilizations_built
		Globals.goals.aliens:
			verb = "Destroy"
			remaining -= aliens_destroyed
			
	var text = verb + " " + str(remaining) + " " + object_name
	Globals.current_hud.update_goal(text)
	

func _on_new_planet_requested(location):
	Globals.current_solar_system.spawn_planet(location)
	planets_spawned += 1

func _on_tree_grown():
	trees_grown += 1

func _on_alien_destroyed():
	aliens_destroyed += 1
	
func _on_civilization_built():
	civilizations_built += 1

func _on_atmosphere_created():
	atmospheres_created += 1

func _on_hyperspace_completed():
	reset_win_conditions()
	spawn_new_solar_system()
	Globals.current_player.exit_hyperspace()

func reset_win_conditions():
	trees_grown = 0
	planets_spawned = 0
	atmospheres_created = 0
	civilizations_built = 0
	aliens_destroyed = 0

func detect_win_condition() -> bool:
	var system : solar_system = Globals.current_solar_system
	var win = false
	match system.goal:
		Globals.goals.trees:
			win = trees_grown >= 3
		Globals.goals.planets:
			win = planets_spawned >= 3
		Globals.goals.aliens:
			win = aliens_destroyed >= 3
		Globals.goals.atmospheres:
			win = atmospheres_created >= 3
		Globals.goals.civilizations:
			win = civilizations_built >= 3
	return win
		
		


func _on_win_condition_monitor_timeout() -> void:
	if detect_win_condition() == true:
		spawn_hyperspace()
	create_goal_hint(Globals.current_solar_system)
