extends RigidBody2D

var interval_between_shots : int = 250 #msec
var time_of_last_shot : int = 0
var current_material : PackedScene

var current_planet : Node2D # get this so you know where projectiles go

var rotation_speed : float = 5.0
var max_velocity : float = 800.0
var thrust : float = 20000.0

var projectile_charge : float = 300.0 # speed to eject particles out of cannon
var projectile_jitter : float = 0.2 # radians of aim deviation

enum states { FLYING, SWIMMING, HYPERSPACE, DYING, DEAD }
var state = states.FLYING

var contacts : Array = []


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
			desired_rotation = clamp(angle_to_mouse, -PI, PI) / PI

	var torque_strength = 100000.0
	apply_torque(desired_rotation * torque_strength)

func spin_whale_clockwise(_delta):
	var torque_strength = 100000.0
	apply_torque(torque_strength)

func apply_thrust(_delta):
	var thrusting = false
	match Globals.control_scheme:
		Globals.control_schemes.WASD:
			thrusting = Input.is_action_pressed("move_forward")
		Globals.control_schemes.MOUSE:
			var void_distance = 96 / get_viewport().get_camera_2d().zoom.x
			thrusting = global_position.distance_squared_to(get_global_mouse_position()) > pow(void_distance, 2)
	if thrusting:
		var forward_dir = transform.x.normalized()
		# Apply a continuous force forward
		if linear_velocity.length_squared() < max_velocity * max_velocity:
			apply_central_force(forward_dir * thrust)

func show_vfx():
	# turn on effects at an arbitrary speed: near half of max?
	if linear_velocity.length_squared() > pow(0.45 * max_velocity, 2):
		$GPUParticles2D.emitting = true
	else:
		$GPUParticles2D.emitting = false


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
	
	# drop falling sand/water/fire/plant toward planet
	var new_projectile : Node2D = projectile_scene.instantiate()

	var muzzle : Marker2D
	if new_projectile.is_in_group("water"):
		muzzle = $MuzzleWater
		$AnimationPlayer.play("blow_water")
	elif new_projectile.is_in_group("dirt"):
		muzzle = $MuzzleDirt
	else:
		muzzle = $Muzzle
		$AnimationPlayer.play("shoot")

	new_projectile.global_position = muzzle.global_position
	new_projectile.global_rotation = muzzle.global_rotation + randf_range(-projectile_jitter, projectile_jitter) #in radians
	
	var dir_vector = muzzle.get_global_transform().x
	#var dir_vector = Vector2.RIGHT.rotated(rotation)
	
	Globals.current_solar_system.get_node("Projectiles").add_child(new_projectile) 
	new_projectile.linear_velocity = dir_vector * projectile_charge + linear_velocity
	
func launch_off_planet(planet):
	if planet == null:
		return
	var escape_boost_force = 500
	var escape_direction = (global_transform.origin - planet.global_position).normalized()
	var gravity_strength = 9.8
	# Boost force increases when closer to planet or in stronger gravity
	var adjusted_boost = escape_boost_force * gravity_strength
	
	apply_central_impulse(escape_direction * adjusted_boost)
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
	 
func _on_hud_ready(hud):
	current_material = Globals.current_hud.current_material
	hud.current_player_controller = self


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name in ["shoot"]:
		$AnimationPlayer.play("swim")


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("planets"):
		launch_off_planet(body)
