extends Control


func _init():
	Globals.current_level = self

func _on_new_planet_requested(location):
	$SolarSystem.spawn_planet(location)
	
