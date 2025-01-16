extends Node2D

var solar_system_scale = 12
var semi_major_axis = pow(2,solar_system_scale)
var semi_minor_axis = pow(2, solar_system_scale - 1)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var num_stars = randi_range(30, 100)
	for i in range(num_stars):
		spawn_star()
	var num_nebulae = randi()%3
	for i in range(num_nebulae):
		spawn_nebula()

func spawn_star():
	var center = Vector2(0, 0)  # center of the ellipse

	var new_star = preload("res://Objects/background_star.tscn").instantiate()
	var point = generate_random_point_in_ellipse(center)
	new_star.position = point
	add_child(new_star)

func spawn_nebula():
	var center = Vector2(0, 0)  # center of the ellipse
	var new_nebula = Sprite2D.new()
	new_nebula.texture = preload("res://assets/images/nebulae.png")
	new_nebula.hframes = 2
	new_nebula.frame = randi()%2
	var point = generate_random_point_in_ellipse(center)
	new_nebula.position = point
	add_child(new_nebula)

func generate_random_point_in_ellipse(center: Vector2) -> Vector2:
	var theta = randf() * 2 * PI
	var r = randf()
	var x = center.x + semi_major_axis * r * cos(theta)
	var y = center.y + semi_minor_axis * r * sin(theta)
	return Vector2(x, y)	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
