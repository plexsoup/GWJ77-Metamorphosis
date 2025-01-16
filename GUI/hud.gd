extends Control

signal material_changed(new_material)
signal hud_ready(hud)

var current_material : 
	set(v): # nothing to set
		current_material = v
		material_changed.emit(current_material)
		update_material_label()
	get:
		return current_material

var current_player_controller


func _init() -> void:
	Globals.current_hud = self

func _ready():
	hud_ready.emit(self) # for the player controller

func update_material_label():
	var reference_material = current_material.instantiate()
	var material_name = reference_material.short_name
	reference_material.queue_free()
	%MaterialLabel.text = "Space to shoot: " + material_name
	

func _on_material_button_pressed(new_material):
	current_material = new_material
