## Clouds
extends Node2D
var max_height = 1200
var min_height = 600
var speed = -1 * randf_range(0.3, 0.75)
var planet

func _ready():
	pick_random_cloud()
	
func pick_random_cloud():
	$Clouds.frame = min(floor(randf() * 4), 3)
	
func _process(delta):
	rotate(speed * delta)

func adjust_height(amount : int):
	var cloud : Sprite2D = $Clouds
	cloud.position.x += amount # local positions
	cloud.position.x = min(cloud.position.x, max_height)
	cloud.position.x = max(cloud.position.x, min_height)
