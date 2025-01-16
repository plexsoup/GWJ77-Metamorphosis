class_name solar_system extends Node2D

@export var goal = Globals.goals.planets
@export var goal_quantity : int = 3
signal goal_updated(goal, quantity)

func _init():
	Globals.solar_system = self




func spawn_planet(location):
	var planet_scene = preload("res://Objects/planet.tscn")
	var new_planet = planet_scene.instantiate()
	new_planet.position = location
	call_deferred("add_child", new_planet)
	#new_planet.global_position = location
	
