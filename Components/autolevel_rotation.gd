## Keep the parent node horizontal, regardless of what it's ancestors are doing.
## - Good for text labels and health bars, etc.
extends Node

@export var custom_rotation : float = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	get_parent().global_rotation = custom_rotation
