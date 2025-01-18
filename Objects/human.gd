extends Node2D

var planet

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	walk_randomly(delta)

func walk_randomly(delta):
	#Find tangent to planet, walk left or right along tangent
	# - tangent will always be ninety degrees to direction between origins.
	var radius = planet.get_radius()
	var vector_to_planet_origin = planet.global_position - global_position
	
