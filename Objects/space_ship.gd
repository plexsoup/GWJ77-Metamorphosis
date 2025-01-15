## Space ship flies around the solar system and tractor-beams up animals and trees.

# might be put out if you shoot dirt at it?


extends Node2D

var speed = 200
var amplitude = 128
var frequency = randf_range(0.003, 0.01)
var start_y : float

enum states { IDLE, SEEKING, BEAMING, FIGHTING, DYING, DEAD }
var state = states.IDLE

var target

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_y = global_position.y


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	move(delta)


func move(delta):
	# Move in a sin wave pattern horizontally across the map
	global_position.x += speed * delta
	global_position.y = sin(global_position.x * frequency) * amplitude + start_y
	
func move_toward_nearest_planet():
	pass
	



func _on_decision_timer_timeout() -> void:
	if state == states.IDLE:
		if randf() < 0.2:
			state = states.SEEKING
			# TODO: Finish this.
		
