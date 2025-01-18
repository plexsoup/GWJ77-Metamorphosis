extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.frame = randi()%($Sprite2D.hframes * $Sprite2D.vframes)
