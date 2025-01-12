extends GridContainer

var hud
signal button_pressed(material)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hud = owner
	button_pressed.connect(hud._on_material_button_pressed)
	hud.material_changed.connect(_on_hud_material_changed)

func _on_button_pressed(material_scene) -> void:
	button_pressed.emit(material_scene)

func _on_hud_material_changed(new_material):
	for child in get_children():
		if child.has_method("_on_hud_material_changed"):
			child._on_hud_material_changed(new_material)
			
