extends Node2D

var speed = 0.2
var original_bird_x = 400

func _ready():
	speed += randf()*(speed * 0.5)
	original_bird_x += randf()*(original_bird_x*0.2)
	$AnimatedSprite2D.position.x = original_bird_x

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate(speed * delta)
	var frequency = 0.5
	var magnitude = 64.0
	$AnimatedSprite2D.position.x = original_bird_x + sin(frequency) * magnitude
