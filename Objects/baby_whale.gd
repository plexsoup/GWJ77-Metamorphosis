##Baby whale, follows the player (SpaceWhale) and flocks to other Baby Whales

extends Node2D

var velocity : Vector2 = Vector2.RIGHT
var speed : float = 450.0
var original_sprite_scale : Vector2
@export var dist_to_avoid = 228

var last_frame_flip_tick : int = 0
var interval_between_flips: int = 400

func _ready():
	original_sprite_scale = $Sprites.scale

func _process(delta):
	flock(delta)
	set_sprite_facing()

func set_sprite_facing():
	var f_time = Time.get_ticks_msec()
	if f_time > last_frame_flip_tick + interval_between_flips:
		last_frame_flip_tick = f_time
		
		if velocity.x > 0:
			$Sprites.scale.x = original_sprite_scale.x * -1
		else:
			$Sprites.scale.x = original_sprite_scale.x

func flock(delta):
	var follow_vector = get_follow_vector()
	var avoidance_vector = get_avoidance_vector()
	var alignment_vector = get_alignment_vector()
	var cohesion_vector = get_cohesion_vector()
	
	var average_vector = average_vectors([follow_vector * 2.0, avoidance_vector * 1.5, alignment_vector, cohesion_vector]) 
	var rotation_speed = 1.0 # TAU (6.3ish) is a full circle
	var angle_to = velocity.angle_to(average_vector)
	var slerp_value = rotation_speed / max(abs(angle_to), 1)
	velocity = velocity.slerp(average_vector, slerp_value * delta)
	global_position += velocity * speed * delta


func average_vectors(vector_list : Array) -> Vector2:
	var total = Vector2.ZERO
	#var count = vector_list.size()
	var non_zero_count = 0
	for vector in vector_list:
		total += vector
		if vector.length_squared() > 0:
			non_zero_count += 1
	var average = total / max(non_zero_count, 1) # prevent divide by zeor crash
	return average

func get_follow_vector():
	var follow_vec := Vector2.ZERO
	if global_position.distance_squared_to(Globals.current_player.global_position) > dist_to_avoid * dist_to_avoid:
		follow_vec = global_position.direction_to(Globals.current_player.global_position)
	return follow_vec

func get_avoidance_vector():
	# find nearby whales and push away from them
	var baby_whales = get_tree().get_nodes_in_group("BabyWhales")
	baby_whales.push_back(Globals.current_player) # don't crowd the mother either
	var nearby_whales = []
	
	var proximity_alert_sq = dist_to_avoid * dist_to_avoid
	for whale in baby_whales:
		if whale.global_position.distance_squared_to(global_position) < proximity_alert_sq:
			nearby_whales.push_back(whale)
	var push_vectors = []
	for whale in nearby_whales:
		push_vectors.push_back((global_position - whale.global_position).normalized())
	return average_vectors(push_vectors)
	
func get_cohesion_vector():
	# direction to average global_position
	var baby_whales = get_tree().get_nodes_in_group("BabyWhales")
	var locations = []
	for baby_whale in baby_whales:
		locations.push_back(baby_whale.global_position)
	var center_of_mass = average_vectors(locations)
	return global_position.direction_to(center_of_mass) # direction_to is normalized

func get_alignment_vector():
	var baby_whales = get_tree().get_nodes_in_group("BabyWhales")
	var velocities = []
	for baby_whale in baby_whales:
		velocities.push_back(baby_whale.velocity)
	return average_vectors(velocities) # velocities are probably normalized, before speed magnitude is applied
		
