class_name solar_system extends Node2D

@export var goal = Globals.goals.planets
@export var goal_quantity : int = 3

@onready var sun = $Sun

@onready var asteroid_spawner

func _init():
	Globals.current_solar_system = self


func _ready():
	validate_dependencies()

func validate_dependencies():
	if not has_node("Projectiles"):
		var projectiles_folder = Node2D.new()
		add_child(projectiles_folder)
	if not has_node("AsteroidSpawner"):
		var new_asteroid_spawner = preload("res://Components/asteroid_spawner.tscn").instantiate()
		add_child(new_asteroid_spawner)
		new_asteroid_spawner.name = "AsteroidSpawner"
		new_asteroid_spawner.global_position = Vector2.RIGHT.rotated(randf()*TAU) * randf_range(2400, 12000)
		
	asteroid_spawner = $AsteroidSpawner

func spawn_planet(location):
	# Note, we're not validating the location, just spawning a planet where told.
	#var nearby_planets = get_nearby_planets(location)
	var planet_scene = preload("res://Objects/planet.tscn")
	var new_planet = planet_scene.instantiate()
	new_planet.position = location # I think we have to use position, not global position, if we want to do this before add_child.
	call_deferred("add_child", new_planet)
	
	if randf() < 1:
		new_planet.gestating = true
	
func get_nearby_planets(location : Vector2):
	var nearby_planets = []
	var tolerance_sq = 512 * 512 # should be 428 though?
	for planet in $Planets.get_children():
		if (planet.global_position - location).length_squared() < tolerance_sq:
			nearby_planets.push_back(planet)
	return nearby_planets
	
