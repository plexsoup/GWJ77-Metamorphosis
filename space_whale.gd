extends RigidBody2D

var interval_between_shots : int = 200 #msec
var time_of_last_shot : int = 0
var current_material : PackedScene

var current_planet : Node2D # get this so you know where projectiles go

var rotation_speed : float = 5.0
var max_velocity : float = 800.0
var thrust : float = 20000.0

var projectile_charge : float = 250.0 # speed to eject particles out of cannon
var projectile_jitter : float = 0.2 # radians of aim deviation

enum states { FLYING, SWIMMING, DYING, DEAD }
var state = states.FLYING

var contacts : Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	Globals.current_hud.material_changed.connect(_on_material_changed)
	Globals.current_hud.hud_ready.connect(_on_hud_ready)
	

func _physics_process(delta: float) -> void:
	if state == states.FLYING:
		rotate_whale(delta)
		apply_thrust(delta)
		show_vfx()

func rotate_whale(_delta):
	var desired_rotation = Input.get_axis("rotate_left", "rotate_right")
	var torque_strength = 100000.0
	apply_torque(desired_rotation * torque_strength)

func apply_thrust(_delta):
	if Input.is_action_pressed("move_forward"):
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
	$AnimationPlayer.play("shoot")
	# drop falling sand/water/fire/plant toward planet
	var new_projectile : Node2D = projectile_scene.instantiate()
	new_projectile.global_position = $Muzzle.global_position
	new_projectile.rotation = rotation + randf_range(-projectile_jitter, projectile_jitter) #in radians
	var dir_vector = Vector2.RIGHT.rotated(rotation)
	add_sibling(new_projectile) # sibling, not child: projectiles shouldn't inherit subsequent spaceship transforms
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
