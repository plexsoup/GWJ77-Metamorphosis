extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	point_to_sun()
	
	
func point_to_sun():
	if Globals.current_solar_system == null or !is_instance_valid(Globals.current_solar_system):
		return
	var sun = Globals.current_solar_system.sun
	global_rotation = (sun.global_position - global_position).angle()

	var tolerance = 1024 * 7
	var my_pos = global_transform.origin
	var vector_to_sun = Globals.current_solar_system.sun.global_position - my_pos
	vector_to_sun.y *= 3.0 # fake an ellipse by pretending the player is twice as far on the y axis
	if vector_to_sun.length_squared() > tolerance * tolerance:
		flash()
	else:
		$Sprite2D.hide()
	
func flash():
	if Engine.get_physics_frames() % 30 == 0:
		$Sprite2D.visible = !$Sprite2D.visible
	
