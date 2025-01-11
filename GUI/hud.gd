extends Control

signal material_changed(new_material)


var current_material : # phantom - passthru var
	set(v): # nothing to set
		current_material = v
		material_changed.emit()
	get:
		return $MaterialPicker.current_material_scene


func _init() -> void:
	Globals.current_hud = self
