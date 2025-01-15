extends Control

var game_scene = preload("res://game_level.tscn")

func _ready():
	%PlayButton.grab_focus()

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
	var next_pos : Vector2
	if $DevNotes.position.x < 0:
		next_pos = positions[1]
	else:
		next_pos = positions[0]

	tween.tween_property($DevNotes, "position", next_pos, 0.5)
	
