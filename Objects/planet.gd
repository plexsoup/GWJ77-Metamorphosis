## Planet

extends Node2D




func _on_biosphere_body_entered(body: Node2D) -> void:
	if body.is_in_group("seeds"):
		# remove the seed and spawn a tree
		if body.has_method("germinate"):
			body.germinate(self)
