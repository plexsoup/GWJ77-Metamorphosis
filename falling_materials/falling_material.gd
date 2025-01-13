class_name falling_material extends RigidBody2D




@export var short_name : String
@export_color_no_alpha var color : Color

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	validate_dependencies()
	
	if $Sprite2D.texture is GradientTexture2D:
		$Sprite2D.texture.gradient.colors[0] = color
	$CollisionShape2D.shape.resource_local_to_scene = true
	
func validate_dependencies():
	# Needs Sprite2D, because each material has a different color
	if not has_node("Sprite2D"):
		print(self.name, " at ", self.scene_file_path, " requires Sprite2D node. queued_free")
		queue_free()
		
