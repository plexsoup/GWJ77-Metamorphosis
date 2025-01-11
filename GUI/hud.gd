extends Control

signal material_changed(new_material)
signal hud_ready(hud)

var current_material : # phantom - passthru var
	set(v): # nothing to set
		current_material = v
		material_changed.emit()
	get:
		return $MaterialPicker.current_material_scene

var current_player_controller


func _init() -> void:
	Globals.current_hud = self

func _ready():
	hud_ready.emit(self) # for the player controller
