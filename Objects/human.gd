extends Node2D

var planet

var direction : int = 1
var speed = 10.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	speed = randf_range(7.5, 15.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	walk_randomly(delta)

func walk_randomly(delta):
	#Find tangent to planet, walk left or right along tangent
	# - tangent will always be ninety degrees to direction between origins.
	#var radius = planet.get_radius()
	var vector_to_planet_origin = planet.global_position - global_position
	var tangent = vector_to_planet_origin.rotated(PI/2.0).normalized()
	global_position += tangent * direction * speed * delta
	if direction > 0:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false
	global_rotation = vector_to_planet_origin.angle() + PI
	

func _on_decision_timer_timeout() -> void:
	if randf() < 0.5:
		direction *= -1
		
