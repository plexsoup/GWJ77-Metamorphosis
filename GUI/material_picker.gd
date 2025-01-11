extends HBoxContainer

var materials = [
	preload("res://falling_materials/FallingSand.tscn"),
	preload("res://falling_materials/FallingWater.tscn"),
]

var current_material_idx = 0
var current_material_scene : PackedScene

signal material_changed(new_material) #connected from parent

func _ready():
	current_material_scene = materials[current_material_idx]


func _on_next_button_pressed() -> void:
	current_material_idx = (current_material_idx + 1) % materials.size()
	current_material_scene = materials[current_material_idx]
	update_material_name_label(current_material_idx)

func _on_prev_button_pressed() -> void:
	current_material_idx = (current_material_idx - 1) % materials.size()
	current_material_scene = materials[current_material_idx]
	update_material_name_label(current_material_idx)


func update_material_name_label(index):
	# Where "material" means sand, water, etc. Not mesh.material or texture
	var packed_material : PackedScene = materials[index]
	current_material_scene = packed_material
	var reference_material = packed_material.instantiate()
	var mat_name = reference_material.short_name
	$MaterialLabel.text = mat_name
	material_changed.emit(packed_material)
	reference_material.queue_free()
