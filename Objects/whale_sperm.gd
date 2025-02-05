## Whale Sperm.
# released from asteroids when they impact planets.
# travels in toward eggs, then makes babies

extends Node2D

var planet

var speed = 12.0

signal reached_center


func _ready():
	speed += randf_range(-speed / 3.0, speed / 3.0)
	if planet != null and planet.has_method("_on_whale_sperm_reached_center"):
		reached_center.connect(planet._on_whale_sperm_reached_center)
	
func _process(delta):
	move_toward_planet_center(delta)
	
func move_toward_planet_center(delta):
	if planet.fertilized == true:
		queue_free()

	else:
		var tolerance = 32
		var tolerance_sq = tolerance * tolerance
		if global_position.distance_squared_to(planet.global_position) > tolerance_sq:
			var dir = global_position.direction_to(planet.global_position)
			global_position += dir * speed * delta
		else:
			reached_center.emit()
