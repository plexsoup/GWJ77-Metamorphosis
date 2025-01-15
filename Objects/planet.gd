## Planet

extends StaticBody2D


var rotation_speed : float = 0.25
var size = 256
var contacts : Array = []
var animal_scenes : Array = [
	preload("res://Objects/bird.tscn"),
	
]


func _ready():
	rotation_speed = randf_range(0.2, 0.4)
	# this will affect cloud movement as well


func spawn_cloud(location):
	var new_cloud = preload("res://Objects/cloud.tscn").instantiate()
	new_cloud.planet = self
	$Atmosphere.add_child(new_cloud)
	new_cloud.rotation = Vector2.RIGHT.angle_to(location - global_position)
	new_cloud.adjust_height(randi_range(-128, 128))
	
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


#func _on_body_entered(body: Node) -> void:
	#if body.is_in_group("seeds"):
		#var seed = body
		#seed.germinate(self, contacts[0][1], contacts[0][2]) # planet, location, normal (in local coords)

#func spawn_animal():
	## pick a random tree and spawn a bird.
	#var tree = $Trees.get_children().pick_random()
	#var location = tree.global_position
	#var new_animal = animal_scenes.pick_random().instantiate()
	#$Animals.add_child(new_animal)
	#new_animal.global_position = global_position
	#new_animal.rotation = (location - global_position).angle()
	#
	


#func _on_spawn_timer_timeout() -> void:
	#if $Animals.get_child_count() < $Trees.get_child_count():
		#if randf() < 0.33:
			#spawn_animal()
			#$SpawnTimer.set_wait_time(randf_range(2.0,5.0))
		#
