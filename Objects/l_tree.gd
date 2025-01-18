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
var segment_length = 128
var line_width = 6
var tree_num : int = -1

func _ready():
	generate_tree()

func generate_tree():
	tree_num += 1
	var tree_root = Node2D.new()
	tree_root.name = "tree"+str(tree_num)
	add_child(tree_root)

	# Randomly choose one set of rules
	var rules = rule_sets.pick_random()
	angle = 25.7 + randf_range(-22.5, 22.5)
	iterations = randi_range(1,3)
	segment_length = randf_range(10.0, 30.0)
	var sentence = process_l_system(axiom, rules, iterations)
	draw_tree_new(sentence, tree_root)


func process_l_system(initial, rules, system_iterations):
	var current = initial
	for _i in range(system_iterations):
		var next = ""
		for character in current:
			if character in rules:
				next += rules[character]
			else:
				next += character
		current = next
	return current

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("change_all_trees"):
		delete_tree()
		generate_tree()

func delete_tree():
	for child in get_children():
		child.queue_free()

func draw_tree_old(sentence : String, root_node : Node2D):
	var stack = []
	var pos = Vector2.ZERO
	var dir = Vector2.RIGHT
	var current_line = null
	
	for character in sentence:
		match character:
			"F", "B", "X":  # Handle all drawing characters here
				if current_line == null:
					current_line = $ReferenceLine.duplicate()
					current_line.show()
					current_line.default_color = Color.WHITE
					current_line.width = line_width
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


func draw_tree_new(sentence : String, root_node : Node2D):
	#print("Tree drawing: ", sentence)
	var stack = []
	var pos = Vector2.ZERO
	var dir = Vector2.RIGHT
	var current_line : Line2D = null
	
	for character in sentence:
		match character:
			"F", "B", "X":  # Handle all drawing characters here
				if current_line == null:
					current_line = Line2D.new()
					current_line.default_color = Color.WHITE
					current_line.width = line_width
					current_line.add_point(pos)
					root_node.add_child(current_line)
				pos += dir * segment_length
				current_line.add_point(pos)
			"+":
				dir = dir.rotated(deg_to_rad(-angle))
			"-":
				dir = dir.rotated(deg_to_rad(angle))
			"[":
				stack.push_back([pos, dir, current_line])
				# Continue with the current line for one branch
			"]":
				var state = stack.pop_back()
				pos = state[0]
				dir = state[1]
				current_line = state[2]  # Continue with the line from before branching
				# Create a new line for the other branch
				var new_line = Line2D.new()
				new_line.default_color = Color.WHITE
				new_line.width = line_width
				new_line.add_point(pos)
				root_node.add_child(new_line)
				current_line = new_line
