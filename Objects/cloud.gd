extends Node2D

func _ready():
	$ReferenceNodes.hide()
	pick_random_cloud()
	
func pick_random_cloud():
	var clouds = $ReferenceNodes.get_children()
	var new_cloud = clouds.pick_random().duplicate()
	add_child(new_cloud)
	new_cloud.show()
	$ReferenceNodes.queue_free()
	
	
