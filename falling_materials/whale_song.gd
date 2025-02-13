## Space Whale can sing.
# if you sing, does it summon asteroids?

extends Node2D

@export var short_name : String
@export_color_no_alpha var color : Color
var contacts : Array = []
var linear_velocity : Vector2 = Vector2.ZERO
const cooldown: int = 2000 # in msec
#var last_response_position : Vector2
#var last_player_pos : Vector2

func _ready():
	$AnimationPlayer.play("sing")
	#trigger_response()


func trigger_response():
	# Set the position of the response
	var response = preload("res://Components/whale_song_response.tscn").instantiate()
	add_sibling(response)
	response.activate()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "sing":
		call_deferred("queue_free")
		
static func get_cooldown():
	return cooldown

func frighten_aliens():
	var potential_aliens = $AlienFrightener.get_overlapping_areas()
	var nearby_aliens = []
	for area in potential_aliens:
		if area.owner.is_in_group("aliens"):
			nearby_aliens.push_back(area.owner)
	for alien in nearby_aliens:
		if alien.has_method("frighten"):
			alien.frighten()
