## Planet

extends RigidBody2D


var rotation_speed : float = 0.25
var size = 256
var contacts : Array = []
var animal_scenes : Array = [
	preload("res://Objects/bird.tscn"),
	
]

signal atmosphere_created
signal civilization_created

var has_atmosphere : bool = false
var has_civilization : bool = false
var spawned_by_player : bool = false
var gestating : bool = false:
	set(v):
		gestating = v
		update_planet_sprite()
	get:
		return gestating
var fertilized : bool = false


func _ready():
	rotation_speed = randf_range(0.2, 0.4)
	$Troposphere/TroposphereBG.hide()
	atmosphere_created.connect(Globals.current_level._on_atmosphere_created)
	civilization_created.connect(Globals.current_level._on_civilization_created)
	update_planet_sprite()

func update_planet_sprite():
	if gestating:
		$PlanetSprite.texture = preload("res://assets/images/gestating_planet.png")
		$PlanetSprite/BabySprite.visible = true
	else:
		$PlanetSprite/BabySprite.visible = false

func fertilize_egg():
	var baby_sprite = $PlanetSprite/BabySprite
	baby_sprite.texture = preload("res://assets/images/baby_whale_intact.png")
	baby_sprite.scale = Vector2(0.1, 0.1)
	fertilized = true
	$BabyGrowthTimer.start()
	#hatch()

func advance_trimester():
	var baby_sprite = $PlanetSprite/BabySprite
	baby_sprite.scale += Vector2(0.1,0.1)
	if baby_sprite.scale.x > 0.4:
		hatch()

func get_radius():
	return $CollisionShape2D.shape.radius

func spawn_cloud(location):
	var new_cloud = preload("res://Objects/cloud.tscn").instantiate()
	new_cloud.planet = self
	$Atmosphere.add_child(new_cloud)
	new_cloud.rotation = Vector2.RIGHT.angle_to(location - global_position)
	new_cloud.adjust_height(randi_range(-128, 128))

	if not has_atmosphere and $Atmosphere.get_child_count() >= 12:
		spawn_atmosphere()
			
func spawn_atmosphere():
	var atmos_sprite = $Troposphere/TroposphereBG
	if not atmos_sprite.is_visible(): # only send signal once
		$Troposphere/TroposphereBG.show()
		atmosphere_created.emit()
		has_atmosphere = true

func spawn_city():
	var rand_rotation = randf()*TAU
	var new_city = preload("res://Objects/city.tscn").instantiate()
	new_city.rotation = rand_rotation
	new_city.position = Vector2.ZERO # on center of planet. (lazy)
	new_city.planet = self
	$Cities.add_child(new_city)
	if not has_civilization and $Cities.get_child_count() > 2:
		civilization_created.emit()
		has_civilization = true


func _process(delta):
	$PlanetSprite.rotate(rotation_speed * delta)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	contacts.clear()
	var num_contacts = state.get_contact_count()
	if num_contacts > 0:
		for i in range(num_contacts):
			var last_contact_position = state.get_contact_local_position(i)
			var last_contact_normal = state.get_contact_local_normal(i)
			var last_contact_object = state.get_contact_collider(i)
			contacts.push_back([last_contact_object, last_contact_position, last_contact_normal])

func _on_asteroid_impacted(_asteroid, collision_point, collision_normal):
	spawn_crack(collision_point, collision_normal)

func spawn_crack(collision_point, _collision_normal):
	if $Cracks.get_child_count() < 4:
		var new_crack = preload("res://Objects/cracks.tscn").instantiate()
		$Cracks.add_child(new_crack)
		new_crack.rotation = (collision_point - global_position).angle()
	else:
		if gestating and fertilized:
			hatch()
		
func wobble():
	var tween = create_tween()
	tween.tween_property($PlanetSprite, "scale", Vector2(1.2, 1.2), 0.2).set_ease(Tween.EASE_IN)
	tween.tween_property($PlanetSprite, "scale", Vector2(1.3, 1.3), 0.1).set_ease(Tween.EASE_OUT)


func hatch():
	if not Globals.current_solar_system:
		return
		
	var new_whale = preload("res://Objects/baby_whale.tscn").instantiate()
	Globals.current_solar_system.get_node("BabyWhales").call_deferred("add_child", new_whale)
	new_whale.global_position = global_position

	spawn_hatch_noise()
	break_planet()

func spawn_hatch_noise():
	# because we want it to outlast the planet
	var new_noise = $HatchNoise.duplicate()
	new_noise.finished.connect(new_noise.queue_free)
	add_sibling(new_noise)
	new_noise.global_position = global_position
	new_noise.play()

	
func break_planet():
	queue_free()

	
func _on_spawn_timer_timeout() -> void:
	if has_atmosphere:
		if randf() < 0.2 and $Cities.get_child_count() < 9:
			spawn_city()


func _on_freeze_timer_timeout() -> void:
	freeze = true
	
	


func _on_troposphere_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body._on_entered_planet_atmosphere(self)


func _on_troposphere_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		body._on_exited_planet_atmosphere(self)

func _on_whale_sperm_reached_center():
	fertilize_egg()


func _on_baby_growth_timer_timeout() -> void:
	if fertilized:
		advance_trimester()
