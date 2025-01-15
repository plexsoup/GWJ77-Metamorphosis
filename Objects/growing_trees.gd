## Growing trees
## get bigger when watered (or near lake)
## maybe spawn seeds when mature.


extends Node2D

var water : float = 0
var max_water : float = 100
var planet
var clouds_spawned : int = 0
var max_clouds : int = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func grow():
	# 3 scales per sprite frame, 3 sprite frames.
	
	var sprite : Sprite2D = $Sprite2D
	sprite.frame = min(floor(water/max_water * (sprite.hframes-1)), sprite.hframes-1)
	sprite.scale = 3* Vector2.ONE * ( water/max_water - sprite.frame / max_water ) * (sprite.hframes -1)
	

func water_tree(amount):
	$WaterParticles.amount = amount
	$WaterParticles.emitting = true
	water += amount
	water = min(water, max_water)
	grow()
	spawn_clouds()

func spawn_clouds():
	if water >= max_water and clouds_spawned < max_clouds:
		if planet.has_method("spawn_cloud"):
			planet.spawn_cloud(global_position)
			clouds_spawned += 1


func is_near_lake(location : Vector2) -> bool:
	if not planet.has_node("Lakes"):
		return false
	var scan_distance_sq = 128*128
	for lake in planet.get_node("Lakes").get_children():
		if lake.global_position.distance_squared_to(location) < scan_distance_sq:
			return true
	return false


func _on_water_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("water"):
		water_tree(10)
		body.queue_free()
	if body.is_in_group("seed"):
		body.queue_free()


func _on_lake_drinking_timer_timeout() -> void:
	if is_near_lake(planet, global_position):
		water_tree(10)
