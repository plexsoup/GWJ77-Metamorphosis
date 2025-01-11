extends CharacterBody2D

var interval_between_shots : int = 200 #msec
var time_of_last_shot : int = 0
var current_material : PackedScene

var current_planet : Node2D # get this so you know where projectiles go

var rotation_speed : float = 5.0
var thrust : float = 7.5

var projectile_charge : float = 500.0 # speed to eject particles out of cannon
var projectile_jitter : float = 0.2 # radians of aim deviation

enum states { FLYING, LANDED }
var state = states.FLYING



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	Globals.current_hud.material_changed.connect(_on_material_changed)
	Globals.current_hud.hud_ready.connect(_on_hud_ready)
	
	$Legs.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if state == states.FLYING:
		var desired_rotation = Input.get_axis("rotate_left", "rotate_right")
		rotate(desired_rotation * delta * rotation_speed)
		if Input.is_action_pressed("move_forward"):
			velocity = lerp(velocity, transform.x * thrust, 10.0 * delta)
		else:
			velocity = lerp(velocity, Vector2.ZERO, 10.0 * delta)
		move_through_particles(velocity)
	elif state == states.LANDED:
		pass


func move_through_particles(_remaining_velocity):
	var collision : KinematicCollision2D = move_and_collide(_remaining_velocity)
	if collision:
		var collider = collision.get_collider()
		if collider.is_in_group("particles"):
			#move_through_particles(_remaining_velocity)
			var push_force = 10.0 * thrust
			collider.apply_central_impulse(-1*collision.get_normal()*push_force)
		elif collider.owner.is_in_group("planets"):
			land_on_planet(collider)


func land_on_planet(collider):
	state = states.LANDED
	look_at(collider.owner.global_position)
	rotate(PI)
	$Legs.show()
	
func take_off():
	state = states.FLYING
	$Legs.hide()
	
func _unhandled_input(_event: InputEvent) -> void:
	if state in [ states.FLYING, states.LANDED ]:
		if Input.is_action_pressed("shoot"):
			var current_time = Time.get_ticks_msec()
			if current_time > time_of_last_shot + interval_between_shots:
				time_of_last_shot = current_time
				spawn_projectile(get_current_material())
	if state == states.LANDED:
		if Input.is_action_just_pressed("move_forward"):
			take_off()

func get_current_material():
	return Globals.current_hud.current_material

func spawn_projectile(projectile_scene):
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


func _on_biosphere_detector_area_entered(area: Area2D) -> void:
	if area.owner.is_in_group("planets"):
		current_planet = area.owner

func _on_biosphere_detector_area_exited(area: Area2D) -> void:
	if area.owner == current_planet:
		current_planet = null

func _on_material_changed(new_material):
	current_material = new_material
	
func _on_hud_ready(hud):
	print("Player sand_cannon thinks hud is ready: ", hud.name)
	current_material = Globals.current_hud.current_material
	hud.current_player_controller = self
