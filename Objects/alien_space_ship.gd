## Space ship flies around the solar system and tractor-beams up animals and trees.

# might be put out if you shoot dirt at it?


extends Node2D

var speed = 200
var amplitude = 128
var frequency = 0.01


enum states { IDLE, SEEKING, KNOCKBACK, BEAMING, FIGHTING, DYING, DEAD }
var state = states.IDLE:
	set(v):
		state = v
		_on_state_changed()
	get:
		return state

var target
var object_in_beam


#var velocity : Vector2
var dir_vector : Vector2 = Vector2.RIGHT
var distance_travelled : float

func _ready() -> void:
	$TractorBeam.hide()
	

func _process(delta: float) -> void:
	move(delta)


func move(delta):
	if state == states.IDLE:
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
	global_position += (dir_vector * speed * delta) + up_component
	

func move_toward_nearest_organic_material(delta):
	# trees and seeds, maybe animals, but not space-whales
	var organics = []
	var seeds = get_tree().get_nodes_in_group("seeds")
	var trees = get_tree().get_nodes_in_group("trees")
	#var animals = get_tree().get_nodes_in_group("animals")
	organics.append_array(seeds)
	organics.append_array(trees)
	var nearest_organic = find_nearest(organics)
	if nearest_organic:
		
		dir_vector = global_position.direction_to(nearest_organic.global_position)
		$TractorBeam.points[1] = dir_vector * 512
		%VacuumArea.rotation = dir_vector.angle()
		var belay_distance = 480
		if global_position.distance_squared_to(nearest_organic.global_position) < belay_distance * belay_distance:
			global_position += dir_vector * speed * delta
	else:
		state = states.IDLE
	
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

func vacuum_up_object(body):
	state = states.BEAMING
	$AnimationPlayer.play("tractor_beam")
	object_in_beam = body
	object_in_beam.z_index = -10
	var tween = create_tween()
	tween.tween_property(object_in_beam, "global_position", self.global_position, 2.0)

func consume_object_in_beam():
	if object_in_beam != null and is_instance_valid(object_in_beam):
		object_in_beam.queue_free()
		object_in_beam = null

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "tractor_beam":
		consume_object_in_beam()
		state = states.IDLE


func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("dirt") or body.is_in_group("seed"):
		# bounce backwards
		var collision_vector = (global_position - body.global_transform.origin).normalized()
		dir_vector = collision_vector
		state = states.KNOCKBACK
		show_hitflash()
		$IframesTimer.start()

func show_hitflash():
	$SpaceshipSprite.set_self_modulate(Color.DARK_RED)
	
func remove_hitflash():
	$SpaceshipSprite.set_self_modulate(Color.WHITE)

func _on_state_changed():
	match state:
		states.IDLE:
			$AnimationPlayer.play("fly")
		states.KNOCKBACK:
			pass


func _on_iframes_timer_timeout() -> void:
	if state == states.KNOCKBACK:
		remove_hitflash()
		dir_vector = Vector2.RIGHT.rotated(randf()*TAU)
		state = states.IDLE

func _on_decision_timer_timeout() -> void:
	if state == states.IDLE:
		if randf() < 0.2:
			state = states.SEEKING
			$SpaceshipSprite.frame = 1
			$SpaceshipSprite/AlienSprite.frame = 1
			%VacuumArea.set_deferred("monitoring", true)
		else: # change course
			dir_vector = dir_vector.rotated(randf()*PI/2.0)
	elif state == states.SEEKING:
		if randf() < 0.2: # give up
			state = states.IDLE
			$SpaceshipSprite.frame = 0
			$SpaceshipSprite/AlienSprite.frame = 0
			%VacuumArea.set_deferred("monitoring", false)
