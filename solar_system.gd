class_name solar_system extends Node2D

@export var goal = Globals.goals.planets
@export var goal_quantity : int = 3

@onready var sun = $Sun



func _init():
	Globals.current_solar_system = self


func _ready():
	validate_dependencies()

func validate_dependencies():
	if not has_node("Projectiles"):
		var projectiles_folder = Node2D.new()
		add_child(projectiles_folder)

func spawn_planet(location):
	var planet_scene = preload("res://Objects/planet.tscn")
	var new_planet = planet_scene.instantiate()
	new_planet.position = location
	call_deferred("add_child", new_planet)
	#new_planet.global_position = location
	
