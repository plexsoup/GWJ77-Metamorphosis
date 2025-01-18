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


func _ready():
	rotation_speed = randf_range(0.2, 0.4)
	$Troposphere/TroposphereBG.hide()
	atmosphere_created.connect(Globals.current_level._on_atmosphere_created)
	civilization_created.connect(Globals.current_level._on_civilization_created)

	

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
	if $Cracks.get_child_count() < 12:
		var new_crack = preload("res://Objects/cracks.tscn").instantiate()
		$Cracks.add_child(new_crack)
		new_crack.rotation = (collision_point - global_position).angle()
	else:
		# TODO: consider destroying planet altogether.
		pass
		


func _on_spawn_timer_timeout() -> void:
	if has_atmosphere:
		if randf() < 0.2 and $Cities.get_child_count() < 9:
			spawn_city()


func _on_freeze_timer_timeout() -> void:
	freeze = true
	
	
