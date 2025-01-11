extends Node2D

# Three different sets of rules for different tree structures
var rule_sets = [
	{
		"F": "FF+[+F-F-F]-[-F+F+F]"
	},
	{
		"F": "F[+F]F[-F][F]",
		"B": "FF"
	},
	{
		"F": "FF-[-F+F+F]+[+F-F-F]",
		"X": "F[+X]F[-X]+X"
	}
]

var axiom = "F"
var angle = 25.7
var iterations = 3
var segment_length = 55.0

func _ready():
	generate_tree()

func generate_tree():
	var tree_root = Node2D.new()
	tree_root.name = "tree"+str(Time.get_ticks_msec()/100)
	add_child(tree_root)

	# Randomly choose one set of rules
	var rules = rule_sets[randi() % rule_sets.size()]
	angle = 25.7 + randi_range(-22.5, 22.5)
	iterations = randf_range(2,4)
	segment_length = randf_range(10.0, 30.0)
	var sentence = process_l_system(axiom, rules, iterations)
	draw_tree(sentence, tree_root)

func process_l_system(initial, rules, iterations):
	var current = initial
	for _i in range(iterations):
		var next = ""
		for char in current:
			if char in rules:
				next += rules[char]
			else:
				next += char
		current = next
	return current

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("change_all_trees"):
		delete_tree()
		generate_tree()

func delete_tree():
	for child in get_children():
		child.queue_free()

func draw_tree(sentence : String, root_node : Node2D):
	var stack = []
	var pos = Vector2.ZERO
	var dir = Vector2.RIGHT
	var current_line = null
	
	for char in sentence:
		match char:
			"F", "B", "X":  # Handle all drawing characters here
				if current_line == null:
					current_line = Line2D.new()
					current_line.default_color = Color.WHITE
					current_line.width = 2
					current_line.add_point(pos)
					root_node.add_child(current_line)
				current_line.add_point(pos + dir * segment_length)
				pos += dir * segment_length
			"+":
				dir = dir.rotated(deg_to_rad(-angle))
			"-":
				dir = dir.rotated(deg_to_rad(angle))
			"[":
				stack.push_back([pos, dir, current_line])
				current_line = null  # Start a new line for the branch
			"]":
				var state = stack.pop_back()
				pos = state[0]
				dir = state[1]
				current_line = state[2]  # Continue with the line from before branching
