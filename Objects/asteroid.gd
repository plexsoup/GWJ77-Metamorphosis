extends RigidBody2D

var max_length = 50
var velocity = Vector2(0, 0)
var trail_points : Array = []
var last_pos : Vector2
var contacts : Array = []

func _ready() -> void:
	velocity.x = randf_range(-20, 50)
	velocity.y = randf_range(-10, 10)
	velocity *= randf_range(5.0, 10.0)
	linear_velocity = velocity
	last_pos = global_position

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

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	contacts.clear()
	var num_contacts = state.get_contact_count()
	if num_contacts > 0:
		for i in range(num_contacts):
			var c_object = state.get_contact_collider_object(i)
			var c_location = state.get_contact_collider_position(i)
			var c_normal = state.get_contact_local_normal(i)
			contacts.push_back([c_object, c_location, c_normal])


func explode():
	set_deferred("contact_monitor", false)
	var asteroid_bits = preload("res://Objects/asteroid_bits.tscn").instantiate()
	call_deferred("add_sibling", asteroid_bits)
	await asteroid_bits.ready
	asteroid_bits.global_transform = global_transform
	call_deferred("queue_free")


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("planets"):
		collide_with_planet(body)

func collide_with_planet(colliding_planet):
		var collision_index = 0
		for contact in contacts:
			if contact[0] == colliding_planet:
				break # break out of the loop
			collision_index += 1
		var collision_point = contacts[collision_index][1]
		var collision_normal = contacts[collision_index][2]
		colliding_planet._on_asteroid_impacted(self, collision_point, collision_normal)
		explode()
		
