extends HBoxContainer

var materials = [
	preload("res://falling_materials/FallingSand.tscn"),
	preload("res://falling_materials/FallingWater.tscn"),
	preload("res://falling_materials/FallingSeed.tscn"),
]

var current_material_idx = 0
var current_material_scene : PackedScene

signal material_changed(new_material) #connected from parent

func _ready():
	current_material_scene = materials[current_material_idx]
	$MaterialLabel.grab_focus()

func _on_next_button_pressed() -> void:
	switch_material(1)

func _on_prev_button_pressed() -> void:
	switch_material(-1)

func switch_material(direction : int):
	current_material_idx = (current_material_idx + direction) % materials.size()
	current_material_scene = materials[current_material_idx]
	update_material_name_label(current_material_idx)
	$MaterialLabel.grab_focus()
	

func update_material_name_label(index):
	# Where "material" means sand, water, etc. Not mesh.material or texture
	var packed_material : PackedScene = materials[index]
	current_material_scene = packed_material
	var reference_material = packed_material.instantiate()
	var mat_name = reference_material.short_name
	$MaterialLabel.text = mat_name
	material_changed.emit(packed_material)
	reference_material.queue_free()


func _on_material_label_pressed() -> void:
	pass # Replace with function body.
