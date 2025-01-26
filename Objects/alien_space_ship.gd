## Space ship flies around the solar system and tractor-beams up animals and trees.

# might be put out if you shoot dirt at it?


extends Node2D

var speed = 200



enum states { IDLE, SEEKING, KNOCKBACK, BEAMING, FLEEING, DYING, DEAD }
var state = states.IDLE:
	set(v):
		state = v
		_on_state_changed()
	get:
		return state

var target
var object_in_beam
var order_of_priority : Array = [
	"humans",
	"seeds"
]

#var velocity : Vector2
var dir_vector : Vector2 = Vector2.RIGHT
var distance_travelled : float

var hits_since_last_flee = 0

func _ready() -> void:
	$TractorBeam.hide()
	

func _process(delta: float) -> void:
	move(delta)


func move(delta):
	if state in [ states.IDLE, states.FLEEING ]:
		move_in_sine_pattern(delta)
	elif state == states.SEEKING:
		move_toward_nearest_organic_material(delta)
	elif state == states.KNOCKBACK:
		var knockback_magnitude = 3.0
		global_position += dir_vector * speed * knockback_magnitude * delta
	

func move_in_sine_pattern(delta: float) -> void:

	var amplitude = 2.5
	var frequency = 0.03 # Waves per distance unit
	distance_travelled += speed * delta

	var displacement: float = amplitude * sin(distance_travelled * frequency)
	var up_component: Vector2 = dir_vector.rotated(-PI/2.0) * displacement
	var boost = 1.0
	if state == states.FLEEING:
		boost = 1.5
	global_position += (dir_vector * speed * delta * boost) + up_component
	

func move_toward_nearest_organic_material(delta):
	# go after humans first, unless there's a seed closer to you
	var organics = []
	for group_name in ["humans", "seeds"]:
		var found_nodes = get_tree().get_nodes_in_group(group_name)
		if found_nodes and not found_nodes.is_empty():
			organics.append_array(found_nodes)
			#print("found ", found_nodes.size(), " " , group_name)
	if organics.is_empty():
		state = states.IDLE
		return
	
	#var nearest_organic = find_nearest(organics)
	var nearest_organic = organics.pick_random()
	if nearest_organic: # or possibly random organic.
		dir_vector = global_position.direction_to(nearest_organic.global_position)
		$TractorBeam.points[1] = dir_vector * 512
		%VacuumArea.rotation = dir_vector.angle()
		var belay_distance = 450
		if global_position.distance_squared_to(nearest_organic.global_position) > belay_distance * belay_distance:
			global_position += dir_vector * speed * delta * 3.5 # provide a boost for seeking organic material

	
func move_toward_nearest_planet():
	pass
	
func find_nearest(array):
	var closest_dist_sq : float = INF
	var closest_item
	for item in array:
		var dist_sq = item.global_position.distance_squared_to(global_position)
		if dist_sq < closest_dist_sq:
			closest_dist_sq = dist_sq
			closest_item = item
	return closest_item




func _on_vacuum_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("planets"):
		return
	if state == states.SEEKING:
		if body.is_in_group("seeds") or body.is_in_group("trees"):
			vacuum_up_object(body)

func _on_vacuum_area_area_entered(area: Area2D) -> void:
	if state != states.SEEKING:
		return
	var object = area.get_parent()
	if object.is_in_group("humans"):
		vacuum_up_object(object)


func vacuum_up_object(object): # body or area
	$TractorBeam.points[1] = object.global_position - global_position
	state = states.BEAMING
	$AnimationPlayer.play("tractor_beam") # end of animation will trigger consume_object_in_beam()
	object_in_beam = object
	object_in_beam.z_index = -10
	if object_in_beam.has_method("_on_tractor_beamed"):
		object_in_beam._on_tractor_beamed(self)
	var tween = create_tween()
	tween.tween_property(object_in_beam, "global_position", self.global_position, 2.0)

func consume_object_in_beam(): # triggered by _on_anim_finished
	if object_in_beam != null and is_instance_valid(object_in_beam):
		object_in_beam.queue_free()
		object_in_beam = null

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "tractor_beam":
		consume_object_in_beam()
		state = states.IDLE


func _on_hit_box_body_entered(body: Node2D) -> void:
	if state == states.KNOCKBACK:
		return
	if body.is_in_group("dirt") or body.is_in_group("seed"):
		# bounce backwards
		var collision_vector = (global_position - body.global_transform.origin).normalized()
		dir_vector = collision_vector
		state = states.KNOCKBACK
		var effect_on_dirt_balls : float = 100
		if body is RigidBody2D:
			body.apply_central_impulse(collision_vector.rotated(PI) * effect_on_dirt_balls )
		show_hitflash()
		play_hurtnoise()
		hits_since_last_flee += 1
		$IframesTimer.start()

	elif body.is_in_group("seeds"):
		if state == states.IDLE:
			state = states.SEEKING
			$GratitudeNoises.play()

func show_hitflash():
	$SpaceshipSprite.set_self_modulate(Color.DARK_RED)
	
func remove_hitflash():
	$SpaceshipSprite.set_self_modulate(Color.WHITE)

func play_hurtnoise():
	$HurtNoises.play()


func _on_state_changed():
	match state:
		states.IDLE:
			$AnimationPlayer.play("fly")
			$SpaceshipSprite.frame = 0
			$SpaceshipSprite/AlienSprite.frame = 0
			%VacuumArea.set_deferred("monitoring", false)
			$FleeLabel.hide()
		states.KNOCKBACK:
			$FleeLabel.hide()
		states.SEEKING:
			$SpaceshipSprite.frame = 1
			$SpaceshipSprite/AlienSprite.frame = 1
			%VacuumArea.set_deferred("monitoring", true)
			$FleeLabel.hide()
		states.FLEEING:
			dir_vector = Globals.current_player.global_position.direction_to(global_position)
			$FleeLabel.show()
			
func frighten():
	state = states.FLEEING
	hits_since_last_flee = 0
	
func _on_iframes_timer_timeout() -> void:
	if state in [states.KNOCKBACK]:
		remove_hitflash()
		dir_vector = Vector2.RIGHT.rotated(randf()*TAU)
		if hits_since_last_flee > 3:
			state = states.FLEEING
			hits_since_last_flee = 0
		else:
			state = states.IDLE


func _on_decision_timer_timeout() -> void:
	if state == states.IDLE:
		if randf() < 0.2:
			state = states.SEEKING

		else: # change course
			# weight toward getting back to galaxy center
			if abs(global_position.y) > 3096 or abs(global_position.x) > 1024 * 8:
				dir_vector = global_position.direction_to(Globals.current_solar_system.sun.global_position)
			dir_vector = dir_vector.rotated(randf()*PI/2.0)
				
	elif state == states.SEEKING:
		if randf() < 0.2: # give up
			state = states.IDLE
	elif state == states.FLEEING:
		state = states.IDLE
		
