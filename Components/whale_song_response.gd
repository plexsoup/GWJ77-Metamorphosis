extends Node2D

func activate():
	$CanvasLayer/Path2D/PathFollow2D.progress_ratio = randf()
	$CanvasLayer/Path2D/PathFollow2D/Waves.look_at($CanvasLayer/Marker2D.global_position)
	$CanvasLayer/AnimationPlayer.play("respond")
	
	#send_asteroids() # moved into animation
	
func send_asteroids():
	var asteroid_spawner = Globals.current_solar_system.asteroid_spawner
	if asteroid_spawner != null:
		var dir = $CanvasLayer/Path2D/PathFollow2D/Waves.global_transform.x
		var player_pos = Globals.current_player.global_position
		var distance_from_player = (get_viewport_rect().size.x / max(get_viewport().get_camera_2d().zoom.x, 0.01)) * 0.67
		var spawn_position = player_pos - (dir * distance_from_player)
		asteroid_spawner.answer_whale_call(5, spawn_position, Globals.current_player.global_position)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "respond":
		queue_free()
