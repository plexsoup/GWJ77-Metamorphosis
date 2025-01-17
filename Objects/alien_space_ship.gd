## Space ship flies around the solar system and tractor-beams up animals and trees.

# might be put out if you shoot dirt at it?


extends Node2D

var speed = 200
var amplitude = 128
var frequency = randf_range(0.003, 0.01)
var start_y : float

enum states { IDLE, SEEKING, BEAMING, FIGHTING, DYING, DEAD }
var state = states.IDLE

var target
var object_in_beam

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_y = global_position.y
	$TractorBeam.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	move(delta)


func move(delta):
	if state == states.IDLE:
		# Move in a sin wave pattern horizontally across the map
		global_position.x += speed * delta
		global_position.y = sin(global_position.x * frequency) * amplitude + start_y
	elif state == states.SEEKING:
		move_toward_nearest_organic_material(delta)

func move_toward_nearest_organic_material(delta):
	# trees and seeds, maybe animals, but not space-whales
	var organics = []
	var seeds = get_tree().get_nodes_in_group("seeds")
	var trees = get_tree().get_nodes_in_group("trees")
	#var animals = get_tree().get_nodes_in_group("animals")
	organics.append_array(seeds)
	organics.append_array(trees)
	var nearest_organic = find_nearest(organics)
	if nearest_organic:
		var dir = global_position.direction_to(nearest_organic.global_position)
		$TractorBeam.points[1] = dir * 512
		%VacuumArea.rotation = dir.angle()
		var belay_distance = 480
		if global_position.distance_squared_to(nearest_organic.global_position) < belay_distance * belay_distance:
			global_position += dir * speed * delta
	else:
		state = states.IDLE
	
func move_toward_nearest_planet():
	pass
	
func find_nearest(array):
	var closest_dist_sq : float = INF
	var closest_item
	for item in array:
		var dist_sq = item.global_position.distance_squared_to(global_position)
		if dist_sq < closest_dist_sq:
			closest_dist_sq = dist_sq
			closest_item = item
	return closest_item

func _on_decision_timer_timeout() -> void:
	if state == states.IDLE:
		if randf() < 0.2:
			state = states.SEEKING
			$Sprite2D.frame = 1
			%VacuumArea.set_deferred("monitoring", true)
	elif state == states.SEEKING:
		if randf() < 0.2: # give up
			state = states.IDLE
			$Sprite2D.frame = 0
			%VacuumArea.set_deferred("monitoring", false)



func _on_vacuum_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("planets"):
		return
	if state == states.SEEKING:
		if body.is_in_group("seeds") or body.is_in_group("trees"):
			vacuum_up_object(body)

func vacuum_up_object(body):
	state = states.BEAMING
	$AnimationPlayer.play("tractor_beam")
	object_in_beam = body
	object_in_beam.z_index = -10
	var tween = create_tween()
	tween.tween_property(object_in_beam, "global_position", self.global_position, 2.0)

func consume_object_in_beam():
	if object_in_beam != null and is_instance_valid(object_in_beam):
		object_in_beam.queue_free()
		object_in_beam = null

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "tractor_beam":
		consume_object_in_beam()
		state = states.IDLE
