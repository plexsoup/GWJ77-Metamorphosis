extends Node2D

var speed = 0.2



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate(speed * delta)
