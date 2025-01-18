## Growing trees
## get bigger when watered (or near lake)
## maybe spawn seeds when mature.


extends Node2D

var water : float = 0
var max_water : float = 100
var planet
var clouds_spawned : int = 0
var max_clouds : int = 2

var animals_spawned : int = 0
var max_animals : int = 1

enum ages { sapling, immature, mature }
var age = ages.sapling

var max_scale = 2.5

signal grown

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grown.connect(Globals.current_level._on_tree_grown)
	max_scale += randf()*(max_scale * 0.25)

func grow():
	# 3 scales per sprite frame, 3 sprite frames.
	
	var sprite : Sprite2D = $Sprite2D
	var new_frame = min(floor(water/max_water * (sprite.hframes-1)), sprite.hframes-1)
	if sprite.frame != new_frame:
		sprite.frame = new_frame
		age = ages.values()[sprite.frame]
		grown.emit()
	sprite.scale = max_scale * Vector2.ONE * ( water/max_water - sprite.frame / max_water ) * (sprite.hframes -1)
	

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

func spawn_animal():
	if planet.get("Animals") or planet.animal_scenes.is_empty():
		return

	var location = self.global_position
	var new_animal = planet.animal_scenes.pick_random().instantiate()
	planet.get_node("Animals").add_child(new_animal)
	new_animal.global_position = planet.global_position
	new_animal.rotation = (location - planet.global_position).angle()
	animals_spawned += 1


func is_near_lake(location : Vector2) -> bool:
	if not planet.has_node("Lakes"):
		return false
	var scan_distance_sq = 128*128
	for lake in planet.get_node("Lakes").get_children():
		if lake.global_position.distance_squared_to(location) < scan_distance_sq:
			return true
	return false

func is_full_grown():
	var sprite : Sprite2D = $Sprite2D
	return sprite.frame == (sprite.hframes * sprite.vframes) - 1

func _on_water_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("water"):
		water_tree(10)
		body.queue_free()
	if body.is_in_group("seed"):
		body.queue_free()


func _on_lake_drinking_timer_timeout() -> void:
	if is_near_lake(global_position):
		water_tree(10)

func _on_spawn_timer_timeout() -> void:
	if not (planet.has_node("Animals") or planet.has_node("Trees")):
		push_warning("Planet needs Animals or Trees node as a folder for organizing objects")
		return
	elif is_full_grown() and animals_spawned < max_animals:
		if randf() < 0.33:
			spawn_animal()
			$SpawnTimer.set_wait_time(randf_range(2.0,5.0))
		
