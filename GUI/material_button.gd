extends TextureButton

@export var material_scene : PackedScene


func _ready():
	pressed.connect(get_parent()._on_button_pressed.bind(material_scene))

func _on_hud_material_changed(new_material):
	if new_material == material_scene:
		button_pressed = true
		grab_focus()
	else:
		button_pressed = false
