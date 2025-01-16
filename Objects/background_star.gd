extends Node2D

enum states { NORMAL, HYPERSPACE }
var state = states.NORMAL
var direction := Vector2.ZERO
const HYPERSPEED = 1200

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var sprite : Sprite2D = $Sprite2D
	sprite.frame = randi()%(sprite.hframes*sprite.vframes)
	
	if randf() < 1.0:
		start_twinkle_timer()
	else:
		$TwinkleTimer.queue_free()

func start_twinkle_timer():
	$TwinkleTimer.set_wait_time(randf_range(2.0,10.0))
	$TwinkleTimer.start()

func twinkle():
	var sprite = $Sprite2D
	sprite.frame = randi()%(sprite.hframes * sprite.vframes)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(2.0, 2.0), 0.2)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

func _on_twinkle_timer_timeout() -> void:
	twinkle()
	start_twinkle_timer()

func _process(delta: float) -> void:
	if state == states.HYPERSPACE:
		global_position += direction * HYPERSPEED * delta


func enter_hyperspace():
	state = states.HYPERSPACE
	#direction = Vector2.ONE.rotated(randf()*TAU)
	direction = (global_position - Globals.current_player.global_position).normalized()
	spawn_trail()
	
func spawn_trail():
	var length = 64
	var new_line = Line2D.new()
	new_line.points = [ Vector2.ZERO, direction * length ]
	new_line.width = 12
	add_child(new_line)
