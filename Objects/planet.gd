## Planet

extends StaticBody2D


var rotation_speed : float = 0.25
var size = 256
var contacts : Array = []
var animal_scenes : Array = [
	preload("res://Objects/bird.tscn"),
	
]

signal atmosphere_created

func _ready():
	rotation_speed = randf_range(0.2, 0.4)
	$Troposphere/TroposphereBG.hide()
	atmosphere_created.connect(Globals.current_level._on_atmosphere_created)

func spawn_cloud(location):
	var new_cloud = preload("res://Objects/cloud.tscn").instantiate()
	new_cloud.planet = self
	$Atmosphere.add_child(new_cloud)
	new_cloud.rotation = Vector2.RIGHT.angle_to(location - global_position)
	new_cloud.adjust_height(randi_range(-128, 128))

	if $Atmosphere.get_child_count() >= 12:
		var atmos_sprite = $Troposphere/TroposphereBG
		if not atmos_sprite.is_visible(): # only send signal once
			$Troposphere/TroposphereBG.show()
			atmosphere_created.emit()
		
		

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
