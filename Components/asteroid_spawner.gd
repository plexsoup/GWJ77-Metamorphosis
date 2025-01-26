extends Node2D

var num_asteroids_per_spawn = 7
var margin_of_error = 2
var likelihood = 0.5
var speed = 450.0
var speed_variation = 150.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func spawn_asteroid():
	var asteroid_speed = speed + randf_range(-speed_variation, speed_variation)
	var vector_to_sun = global_position.direction_to(Globals.current_solar_system.sun.global_position)
	var deviation = randf_range(-0.5, 0.5)
	var new_asteroid = preload("res://Objects/asteroid.tscn").instantiate()
	var rand_x = randf_range(-256, 256)
	var rand_y = randf_range(-256, 256)
	new_asteroid.global_position = global_position + Vector2(rand_x, rand_y)
	Globals.current_solar_system.get_node("Asteroids").add_child(new_asteroid)
	new_asteroid.linear_velocity = vector_to_sun.rotated(deviation) * asteroid_speed

func spawn_asteroids(num):
	for i in range(num):
		spawn_asteroid()
	

func _on_spawn_timer_timeout() -> void:
	if randf() < likelihood:
		spawn_asteroids(num_asteroids_per_spawn + randi_range(-margin_of_error, margin_of_error))
