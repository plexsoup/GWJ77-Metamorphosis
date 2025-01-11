extends Control

var game_scene = preload("res://game_level.tscn")


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_packed(game_scene)
	


func _on_strange_button_pressed() -> void:
	slide_dev_notes()
	
func slide_dev_notes():
	var positions = [
		Vector2(-482, 210),
		Vector2(316, 210)
	]
	var tween = create_tween()
	var current_pos_idx = positions.find($DevNotes.position)
	var new_pos_idx = ( current_pos_idx +1 ) % positions.size()
	tween.tween_property($DevNotes, "position", positions[new_pos_idx], 0.5)
	
