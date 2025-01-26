extends RigidBody2D

var interval_between_shots : int = 330 #msec
var time_of_last_shot : int = 0
var current_material : PackedScene

var current_planet : Node2D # get this so you know where projectiles go

var rotation_speed : float = 5.0
var max_velocity : float = 800.0
var thrust : float = 20000.0
var thrusting = false

var default_projectile_charge : float = 500
var projectile_charge : float = 500.0 # speed to eject particles out of cannon
var projectile_jitter : float = 0.2 # radians of aim deviation

enum states { FLYING, SWIMMING, HYPERSPACE, DYING, DEAD }
var state = states.FLYING

var contacts : Array = []
var in_planetary_atmospheres : Array = []

func _init():
	Globals.current_player = self
	
func _ready() -> void:
	
	Globals.current_hud.material_changed.connect(_on_material_changed)
	Globals.current_hud.hud_ready.connect(_on_hud_ready)
	state = states.FLYING

func _physics_process(delta: float) -> void:
	if not is_visible_in_tree():
		return # for transitions between scenes
		
	if state == states.FLYING:
		rotate_whale(delta)
		apply_thrust(delta)
		show_vfx()
		if Input.is_action_pressed("shoot"):
			attempt_to_shoot() # after applying thrust, so we know how fast to send.
	elif state == states.HYPERSPACE:
		spin_whale_clockwise(delta)

		

func rotate_whale(_delta):
	var desired_rotation : float
	match Globals.control_scheme:
		Globals.control_schemes.WASD:
			desired_rotation = Input.get_axis("rotate_left", "rotate_right")
		Globals.control_schemes.MOUSE:
			# with our position and forward vector, we can dot product the perpendicular
			var vector_to_mouse = get_global_mouse_position() - global_position
			var angle_to_mouse = transform.x.angle_to(vector_to_mouse)
			var soft_zone = PI/2.0
			desired_rotation = clamp(angle_to_mouse, -soft_zone, soft_zone) / soft_zone # value from zero to one

	var torque_strength = 100000.0
	apply_torque(desired_rotation * torque_strength)

func spin_whale_clockwise(_delta):
	var torque_strength = 100000.0
	apply_torque(torque_strength)

func apply_thrust(_delta):
	
	var desired_thrust = thrust
	match Globals.control_scheme:
		Globals.control_schemes.WASD:
			thrusting = Input.is_action_pressed("move_forward")
		Globals.control_schemes.MOUSE:
			var void_distance = 96 / get_viewport().get_camera_2d().zoom.x
			#var dist_to_mouse = global_position.distance_to(get_global_mouse_position())
			#var normalized_dist = dist_to_mouse * get_viewport().get_camera_2d().scale.x
			var viewport_mouse_pos = get_viewport().get_mouse_position()
			var viewport_center = get_viewport_rect().size / 2.0
			var dist_to_mouse = viewport_center.distance_to(viewport_mouse_pos)
			
			desired_thrust = clamp(dist_to_mouse / get_viewport_rect().size.y,0.0,1.0) * thrust
			if dist_to_mouse > void_distance:
				thrusting = true
	if thrusting:
		var forward_dir = transform.x.normalized()
		# Apply a continuous force forward
		if linear_velocity.length_squared() < max_velocity * max_velocity:
			apply_central_force(forward_dir * desired_thrust)

func show_vfx():
	# turn on effects at an arbitrary speed: near half of max?
	if linear_velocity.length_squared() > pow(0.45 * max_velocity, 2):
		$GPUParticles2D.emitting = true
	else:
		$GPUParticles2D.emitting = false


	

#func wrap_around_map_if_necessary():
	## DO NOT USE: this works once, but fails the second time?!
	#if not Globals.current_solar_system or not is_instance_valid(Globals.current_solar_system):
		#return
	#
	#var tolerance = 1024 * 4
	#var vector_to_sun = Globals.current_solar_system.sun.global_position - global_transform.origin
	## cheat an ellipse by doubling our apparent y position
	##vector_to_sun.y *= 2.0
	#
	#if vector_to_sun.length_squared() > tolerance * tolerance:
		#var new_virtual_position = global_position + (2.0 * vector_to_sun)
		#new_virtual_position.y /= 2.0
		#Globals.teleport_rigid_body(self, new_virtual_position)
		##Globals.teleport_rigid_body(self, Vector2.ZERO)
		#
		#$Camera2D.global_position = global_position



func attempt_to_shoot():
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
	
	# drop falling sand/water/fire/plant toward planet
	var new_projectile : Node2D = projectile_scene.instantiate()

	var muzzle : Marker2D
	if new_projectile.is_in_group("water"):
		muzzle = $MuzzleWater
		#muzzle = $Muzzle # wasn't fun to shoot from blow-hole
		$AnimationPlayer.play("blow_water")
		projectile_charge = default_projectile_charge * 1.5
	elif new_projectile.is_in_group("dirt"):
		muzzle = $MuzzleDirt
		#muzzle = $Muzzle # wasn't fun to shoot backwards
		$AnimationPlayer.play("throw_dirt")
		projectile_charge = default_projectile_charge
	elif new_projectile.is_in_group("seeds") or new_projectile.is_in_group("songs"):
		muzzle = $Muzzle
		$AnimationPlayer.play("shoot")
		projectile_charge = default_projectile_charge * 2.0
	if thrusting:
		projectile_charge *= 1.5
	if not in_planetary_atmospheres.is_empty():
		projectile_charge *= 0.5 # slow down shots inside planets

	new_projectile.global_position = muzzle.global_position
	new_projectile.global_rotation = muzzle.global_rotation + randf_range(-projectile_jitter, projectile_jitter) #in radians
	
	var dir_vector = muzzle.get_global_transform().x
	if Globals.control_scheme == Globals.control_schemes.MOUSE:
		dir_vector = muzzle.global_position.direction_to(get_global_mouse_position())

	
	if Globals.current_solar_system != null and is_instance_valid(Globals.current_solar_system):
		if Globals.current_solar_system.has_node("Projectiles"):
			Globals.current_solar_system.get_node("Projectiles").add_child(new_projectile) 
			new_projectile.linear_velocity = dir_vector * projectile_charge
			# Project player's velocity onto the direction vector
			var projected_velocity = linear_velocity.project(dir_vector)
			new_projectile.linear_velocity += projected_velocity

		else:
			push_warning("Solar System requires Projectiles node.")
	else: # Between solar systems.
		new_projectile.queue_free()
		
	
func launch_off_planet(planet):
	if planet == null:
		return
	var escape_boost_force = 500
	var escape_direction = (global_transform.origin - planet.global_position).normalized()
	var gravity_strength = 9.8
	# Boost force increases when closer to planet or in stronger gravity
	var adjusted_boost = escape_boost_force * gravity_strength
	$BounceNoise.play()
	apply_central_impulse(escape_direction * adjusted_boost)
	planet.wobble()
	# ... rest of the function

func enter_hyperspace():
	state = states.HYPERSPACE
	gravity_scale = 0
	set_deferred("linear_velocity", Vector2.ZERO)

func exit_hyperspace():
	state = states.FLYING
	gravity_scale = 1

func _on_material_changed(new_material):
	current_material = new_material
	var ref_material = new_material.instantiate()
	if ref_material.has_method("get_cooldown"):
		interval_between_shots = ref_material.get_cooldown()
	else:
		interval_between_shots = 330 # third of a second
	ref_material.queue_free()
	 
func _on_hud_ready(hud):
	current_material = Globals.current_hud.current_material
	hud.current_player_controller = self


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name in ["shoot", "blow_water", "throw_dirt"]:
		$AnimationPlayer.play("swim")


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("planets"):
		launch_off_planet(body)


func _on_entered_planet_atmosphere(planet):
	if not in_planetary_atmospheres.has(planet):
		in_planetary_atmospheres.push_back(planet)
	
func _on_exited_planet_atmosphere(planet):
	in_planetary_atmospheres.erase(planet)
