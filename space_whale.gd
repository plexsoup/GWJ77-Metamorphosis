extends CharacterBody2D

var interval_between_shots : int = 200 #msec
var time_of_last_shot : int = 0
var current_material : PackedScene

var current_planet : Node2D # get this so you know where projectiles go

var rotation_speed : float = 5.0
var max_velocity : float = 20.0
var thrust : float = 1.0

var projectile_charge : float = 500.0 # speed to eject particles out of cannon
var projectile_jitter : float = 0.2 # radians of aim deviation

enum states { FLYING, SWIMMING, DYING, DEAD }
var state = states.FLYING

var contacts : Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	Globals.current_hud.material_changed.connect(_on_material_changed)
	Globals.current_hud.hud_ready.connect(_on_hud_ready)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if state == states.FLYING:
		rotate_whale(delta)
		apply_thrust(delta)
		push_particles(velocity)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	# Fill contacts array with [object, location, normal]
	contacts.clear()
	var num_contacts = state.get_contact_count()
	if num_contacts > 0:
		for i in range(num_contacts):
			var c_object = state.get_contact_collider_object(i)
			var c_location = state.get_contact_collider_position(i)
			var c_normal = state.get_contact_local_normal(i)
			contacts.push_back([c_object, c_location, c_normal])


func rotate_whale(delta):
	var desired_rotation = Input.get_axis("rotate_left", "rotate_right")
	rotate(desired_rotation * delta * rotation_speed)

func apply_thrust(delta):
	if Input.is_action_pressed("move_forward"):
		velocity = lerp(velocity, transform.x * max_velocity, thrust * delta)
	else:
		velocity = lerp(velocity, Vector2.ZERO, 10.0 * delta)
	if velocity.length_squared() > 0.2 :
		$GPUParticles2D.emitting = true
	else:
		$GPUParticles2D.emitting = false


func push_particles(_remaining_velocity):
	var collision : KinematicCollision2D = move_and_collide(_remaining_velocity)
	var mass = 25.0
	if collision:
		var collider : PhysicsBody2D = collision.get_collider()
		if collider is RigidBody2D and collider.is_in_group("particles") or collider.is_in_group("asteroids"):
			var normal = collision.get_normal()
			var location = collision.get_position()
			var push_force = 10.0 * thrust * mass
			#collider.apply_central_impulse(-1*collision.get_normal()*push_force)
			
			# Calculate the push direction (weighted average of velocity and normal)
			var velocity_direction = _remaining_velocity.normalized()
			var push_direction = (velocity_direction - normal).normalized()
			
			#collider.apply_impulse(normal * push_force, location)
			collider.apply_impulse(push_direction * push_force, location)

#func push_particles(_remaining_velocity):
		#var collision : KinematicCollision2D = move_and_collide(_remaining_velocity)
		#
		#if collision:
				#var collider : PhysicsBody2D = collision.get_collider()
				#if collider is RigidBody2D and (collider.is_in_group("particles") or collider.is_in_group("asteroids")):
						#var normal = collision.get_normal()
						#var collision_point = collision.get_position()
						#
						## Use the velocity direction as the push direction
						#var push_direction = _remaining_velocity.normalized()
						#var push_force = 10.0 * thrust  # Adjust multiplier as needed
						#
						## Apply the force at the point of collision
						#collider.apply_force(push_direction * push_force, collision_point - collider.global_position)
	#
func _unhandled_input(_event: InputEvent) -> void:
	if state in [ states.FLYING ]:
		if Input.is_action_pressed("shoot"):
			shoot()

func shoot():
	var current_time = Time.get_ticks_msec()
	if current_time > time_of_last_shot + interval_between_shots:
		time_of_last_shot = current_time
		spawn_projectile(get_current_material())
		$ShootNoise.play()

func get_current_material():
	var projectile_material = Globals.current_hud.current_material
	if projectile_material == null:
		projectile_material = load("res://falling_materials/FallingDirt.tscn")
	return projectile_material

func spawn_projectile(projectile_scene):
	$AnimationPlayer.play("shoot")
	# drop falling sand/water/fire/plant toward planet
	var new_projectile : Node2D = projectile_scene.instantiate()
	new_projectile.global_position = $Muzzle.global_position
	new_projectile.rotation = rotation + randf_range(-projectile_jitter, projectile_jitter) #in radians
	var dir_vector = Vector2.RIGHT.rotated(rotation)
	add_sibling(new_projectile) # sibling, not child: projectiles shouldn't inherit subsequent spaceship transforms
	if Input.is_action_pressed("move_forward"):
		# note: self.velocity is spaceship velocity. We should use that to modify the projectile initial velocity
		new_projectile.linear_velocity = 2.0 * dir_vector * projectile_charge
	else:
		new_projectile.linear_velocity = 1.0 * dir_vector * projectile_charge


func _on_material_changed(new_material):
	current_material = new_material
	 
func _on_hud_ready(hud):
	current_material = Globals.current_hud.current_material
	hud.current_player_controller = self


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name in ["shoot"]:
		$AnimationPlayer.play("swim")
