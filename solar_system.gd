extends Node2D

func _init():
	Globals.solar_system = self

func spawn_planet(location):
	var planet_scene = preload("res://Objects/planet.tscn")
	var new_planet = planet_scene.instantiate()
	new_planet.position = location
	call_deferred("add_child", new_planet)
	#new_planet.global_position = location
	
