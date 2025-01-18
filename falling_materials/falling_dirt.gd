extends falling_material

var size = 32


signal request_planet(location)

var animal_scenes : Array = [
	preload("res://Objects/bird.tscn"),
]

func set_size(diameter) -> bool: # return success or failure
	var success = false
	if diameter > 256:
		success = become_planet()
	else:
		# resize the sprite scale based on original sprite size and new diameter
		
		#$CollisionShape2D.shape = CircleShape2D.new() # shapes are shared between nodes, so we need a new shape.
		$CollisionShape2D.shape.radius = diameter / 2
		$Sprite2D.scale = Vector2.ONE * (diameter / $Sprite2D.texture.get_size().x)
		size = $Sprite2D.scale.x * $Sprite2D.texture.get_size().x
		mass = diameter * 0.15
		success = true
	return success

func become_planet() -> bool: # return success or failure
	var success : bool = false
	#var safe_location = get_safe_location_for_planet(global_position)
	var safe_location = global_position # Hack. We switched planet to rigid body to let the physics engine handle safe locations.
	if not safe_location:
		success = false
	else:
		disable_collisions()
		request_planet.connect(Globals.current_level._on_new_planet_requested)
		request_planet.emit(safe_location)
		call_deferred("queue_free")
		success = true
	return success
	
func get_safe_location_for_planet(location):
	var planet_diameter = 428
	var max_iterations = 25
	var current_iteration = 0
	while current_iteration < max_iterations:
		var overlapping_planets = Globals.current_solar_system.get_nearby_planets(location)
		if overlapping_planets.size() == 0:
			return location
		else:
			var average_nudge_vector = Vector2.ZERO
			for planet in overlapping_planets:
				var push_strength = 1.0
				var overlap = planet_diameter - planet.global_position.distance_to(location)
				average_nudge_vector += planet.global_position.direction_to(location) * push_strength * clamp(overlap, 0, planet_diameter)
			average_nudge_vector /= max(overlapping_planets.size(), 1)
			location += average_nudge_vector
		current_iteration += 1
	push_warning("Max iterations reached in falling_dirt.get_safe_location_for_planet")


func disable_collisions():
	$CollisionShape2D.set_deferred("disabled", true)
	self.set_deferred("contact_monitor", false)
	self.collision_layer = 0
	self.collision_mask = 0

func get_diameter() -> float:
	return $Sprite2D.scale.x * $Sprite2D.texture.get_size().x


func can_merge(other_ball) -> bool:
	# only merge balls of equal size? Suika style?
	var ok_to_merge = true
	if (
			self.get_diameter() != other_ball.get_diameter() # large balls absorb smaller balls
			or self.get_index() > other_ball.get_index() # ties go to whoever is higher in the tree
			or size > 256 # very large balls turn into planets instead
		):
			ok_to_merge = false
	return ok_to_merge


func absorb_sand_ball(smaller_ball):
	# TODO: resize yourself by adding the smaller ball size,
	# then queue_free the smaller ball and offset your position a bit?
	var new_diameter = self.get_diameter() + smaller_ball.get_diameter()
	var success = set_size(new_diameter)
	if success:
		smaller_ball.queue_free()
	$MergeNoise.play()


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("dirt") and body.has_method("absorb_sand_ball"):
		# make a new ball twice as big, and remove the previous two
		if can_merge(body): # only one of us should make the merge..
			absorb_sand_ball(body)
