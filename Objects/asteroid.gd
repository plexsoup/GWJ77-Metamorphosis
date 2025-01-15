extends RigidBody2D

var max_length = 50
var velocity = Vector2(0, 0)
var trail_points : Array = []
var last_pos : Vector2


func _ready() -> void:
	velocity.x = randf_range(-20, 50)
	velocity.y = randf_range(-10, 10)
	velocity *= randf_range(5.0, 10.0)
	linear_velocity = velocity

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass # let the physics engine handle asteroid movement
	
func update_comet_trail():
	
	#$CometTrail.points[1] = -linear_velocity * 1.25
	$CometTrail.points[1] = (last_pos - global_position) * 5.0
	last_pos = global_position
	#$Sprite2D.rotation = linear_velocity.angle()

func _on_trail_process_timer_timeout() -> void:
	update_comet_trail()
