class_name falling_material extends RigidBody2D




@export var short_name : String
@export_color_no_alpha var color : Color
var contacts : Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	validate_dependencies()
	$CollisionShape2D.shape.resource_local_to_scene = true
	
func validate_dependencies():
	# Needs Sprite2D, because each material has a different color
	if not has_node("Sprite2D"):
		queue_free()

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	contacts.clear()
	var num_contacts = state.get_contact_count()
	if num_contacts > 0:
		for i in range(num_contacts):
			var c_object = state.get_contact_collider_object(i)
			var c_location = state.get_contact_collider_position(i)
			var c_normal = state.get_contact_local_normal(i)
			contacts.push_back([c_object, c_location, c_normal])


func is_near_lake(planet, location : Vector2) -> bool:
	# seeds and water need this
	if not planet.has_node("Lakes"):
		return false
	var scan_distance_sq = 128*128
	for lake in planet.get_node("Lakes").get_children():
		if lake.global_position.distance_squared_to(location) < scan_distance_sq:
			return true
	return false

func _process(_delta: float) -> void:
	if Engine.get_process_frames() % 30 == 0:
		free_if_out_of_bounds()


func free_if_out_of_bounds():
	if $VisibleOnScreenNotifier2D.is_on_screen():
		return # don't clear things the player can see.
	else:
		if abs(global_position.y) > 5096 or abs(global_position.x) > 1024 * 12:
			call_deferred("queue_free")
