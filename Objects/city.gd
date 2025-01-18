extends Node2D

var planet

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.




func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("trees"):
		area.get_parent().queue_free()


func spawn_human():
	var new_human = preload("res://Objects/human.tscn").instantiate()
	new_human.planet = planet
	add_child(new_human)

func _on_spawn_timer_timeout() -> void:
	if randf() < 0.2:
		spawn_human()
		
