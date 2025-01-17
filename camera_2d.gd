extends Camera2D

var zoom_delay : int = 500 # msec
var time_out_of_zoom_spec_detected: int = 0
var zoom_extents = [ Vector2(0.5,0.5), Vector2(0.125,0.125) ]

enum states { IDLE, ZOOMING_IN, ZOOMING_OUT }
var state = states.IDLE
var position_last_frame : Vector2
var velocity_last_frame : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if (not Globals.current_player) or (not is_instance_valid(Globals.current_player)):
		return
		
	var inv_vel_ratio = max(1 - (Globals.current_player.get_linear_velocity() / Globals.current_player.max_velocity).length(), 0) 
	# 0.25 for high speed, 1.0 for low speed
	var max = 1.0
	var min = 0.25
	var adjusted_zoom = (max-min) * inv_vel_ratio + min
	
	zoom_camera(Vector2.ONE * adjusted_zoom, delta)


func zoom_delay_finished():
	return Time.get_ticks_msec() > time_out_of_zoom_spec_detected + zoom_delay


func zoom_camera(desired_zoom, delta):
	var zoom_speed = 0.67
	zoom = lerp(zoom, desired_zoom, zoom_speed * delta)
	if zoom.is_equal_approx(desired_zoom):
		state = states.IDLE
