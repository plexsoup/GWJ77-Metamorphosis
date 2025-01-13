extends falling_material

var size = 32


signal request_planet(location)


func set_size(diameter):
	if diameter > 256:
		become_planet()
	else:
		# resize the sprite scale based on original sprite size and new diameter
		
		#$CollisionShape2D.shape = CircleShape2D.new() # shapes are shared between nodes, so we need a new shape.
		$CollisionShape2D.shape.radius = diameter / 2
		$Sprite2D.scale = Vector2.ONE * (diameter / $Sprite2D.texture.get_size().x)
		size = $Sprite2D.scale.x * $Sprite2D.texture.get_size().x

func become_planet():
	disable_collisions()
	request_planet.connect(Globals.current_level._on_new_planet_requested)
	request_planet.emit(self.global_transform.origin)
	queue_free()
	


func disable_collisions():
	$CollisionShape2D.set_deferred("disabled", true)
	self.set_deferred("contact_monitor", false)
	self.collision_layer = 0
	self.collision_mask = 0

func get_diameter() -> float:
	return $Sprite2D.scale.x * $Sprite2D.texture.get_size().x


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("SandBall"):
		# make a new ball twice as big, and remove the previous two
		if can_merge(body): # only one of us should make the merge..
			absorb_sand_ball(body)

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
	set_size(new_diameter)
	smaller_ball.queue_free()
	$MergeNoise.play()
