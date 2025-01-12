## hides or queues_free any node it's placed inside
## (immediate parent only, not owner or some other ancestor)
## (obviously, if the parent goes, then all it's children go too.)

extends Node

@export var delay: float = 10.0
@export var free_on_timeout : bool = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var timer = Timer.new()
	timer.set_wait_time(delay)
	timer.autostart = true
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)

func _on_timer_timeout():
	get_parent().hide()
	if free_on_timeout:
		get_parent().queue_free()
