extends "res://falling_materials/falling_material.gd"

var size = 32


signal request_planet(location)


func set_size(diameter):
	if diameter > 256:
		become_planet()
	
	# make a new Circle CollisionShape2D with the correct diameter
	# resize the sprite scale based on original sprite size and new diameter
	$CollisionShape2D.shape = CircleShape2D.new()
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
		if size > 256 or body.get_diameter() > 256:
			return
		if self.get_index() > body.get_index(): # only one of us should make the merge..
			merge_sand_balls([self, body])

func merge_sand_balls(balls):
		if balls.is_empty():
			return
		var total_diameter = 0
		var position_sum = Vector2.ZERO
		for ball in balls:
			ball.disable_collisions()
			total_diameter += ball.get_diameter()
			position_sum += ball.global_position
		var average_position = position_sum / balls.size()
			
			
		var new_sand_ball = preload("res://falling_materials/FallingSand.tscn").instantiate()
		new_sand_ball.global_position = average_position
		new_sand_ball.set_size( total_diameter )
		call_deferred("add_sibling", new_sand_ball)
		
		for ball in balls:
			ball.queue_free()
