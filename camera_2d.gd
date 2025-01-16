extends Camera2D

var zoom_delay : int = 500 # msec
var time_out_of_zoom_spec_detected: int = 0
var zoom_extents = [ Vector2(0.5,0.5), Vector2(0.125,0.125) ]

enum states { IDLE, ZOOMING_IN, ZOOMING_OUT }
var state = states.IDLE


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("move_forward"):
		state = states.ZOOMING_OUT
		time_out_of_zoom_spec_detected = Time.get_ticks_msec()
	elif Input.is_action_just_released("move_forward"):
		state = states.ZOOMING_IN
		time_out_of_zoom_spec_detected = Time.get_ticks_msec()

	if state in [states.ZOOMING_IN, states.ZOOMING_OUT] and zoom_delay_finished():
		var desired_zoom
		if Input.is_action_pressed("move_forward"):
			desired_zoom = zoom_extents[1]
		else:
			desired_zoom = zoom_extents[0]
		zoom_camera(desired_zoom, delta)
		



func zoom_delay_finished():
	return Time.get_ticks_msec() > time_out_of_zoom_spec_detected + zoom_delay


func zoom_camera(desired_zoom, delta):
	var zoom_speed = 0.67
	zoom = lerp(zoom, desired_zoom, zoom_speed * delta)
	if zoom.is_equal_approx(desired_zoom):
		state = states.IDLE
