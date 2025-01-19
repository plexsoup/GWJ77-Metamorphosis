extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var explosion_magnitude = 10.0
	$LeftBit.apply_central_impulse($LeftBit.position * explosion_magnitude)
	$RightBit.apply_central_impulse($RightBit.position * explosion_magnitude)
	$BottomBit.apply_central_impulse($BottomBit.position * explosion_magnitude)
	$CrashNoise.play()


func _on_duration_timer_timeout() -> void:
	queue_free()
	
