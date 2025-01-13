## Growing trees
## get bigger when watered (or near lake)
## maybe spawn seeds when mature.


extends Node2D

var water : float = 0
var max_water : float = 100
var planet


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	planet = owner # trees are added to planets when seeds germinate


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
	
func is_near_lake():
	# ask the planet if there are any nearby lakes.
	if planet != null and planet.has_method("is_near_lake"):
		return planet.is_near_lake(global_position)

func _on_water_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("water"):
		water_tree(10)
		body.queue_free()


func _on_lake_drinking_timer_timeout() -> void:
	if is_near_lake():
		water_tree(10)
