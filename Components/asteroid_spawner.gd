extends Node2D

var num_asteroids_per_spawn = 7
var margin_of_error = 2
var likelihood = 0.5
var speed = 450.0
var speed_variation = 150.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func spawn_asteroid(initial_speed):
	var deviation = randf_range(-0.5, 0.5)
	var new_asteroid = preload("res://Objects/asteroid.tscn").instantiate()
	var rand_x = randf_range(-256, 256)
	var rand_y = randf_range(-256, 256)
	new_asteroid.global_position = global_position + Vector2(rand_x, rand_y)
	Globals.current_solar_system.get_node("Asteroids").add_child(new_asteroid)
	new_asteroid.linear_velocity = transform.x.rotated(deviation) * initial_speed

func spawn_asteroids(num, location):
	look_at(location)
	for i in range(num):
		spawn_asteroid(speed)
	
func answer_whale_call(num, source_location, target_location):
	var prev_position = global_position
	# spawn asteroids from 2 screen sizes away, so they don't appear to emerge from a single point.
	global_position = source_location
	look_at(target_location)
	for i in range(num):
		spawn_asteroid(speed * 5.0)
	global_position = prev_position
	

func _on_spawn_timer_timeout() -> void:
	if randf() < likelihood:
		spawn_asteroids(num_asteroids_per_spawn + randi_range(-margin_of_error, margin_of_error), Globals.current_solar_system.sun.global_position)
