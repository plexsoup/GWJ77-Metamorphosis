extends Node2D

var axiom = "F"
var rules = {
	"F": "FF+[+F-F-F]-[-F+F+F]"
}
var angle = 25.7
var iterations = randi_range(1,3)

func _ready():
	generate_tree()

func generate_tree():
	var sentence = process_l_system(axiom, rules, iterations)
	draw_tree(sentence)

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

func draw_tree(sentence):
	var stack = []
	var pos = Vector2.ZERO
	var dir = Vector2.UP
	var current_line = null
	
	for char in sentence:
		match char:
			"F":
				var length = 15
				if current_line == null:
					current_line = Line2D.new()
					current_line.default_color = Color.WHITE
					current_line.width = 2  # You can adjust this for tapering if needed
					current_line.add_point(pos)
					add_child(current_line)
				current_line.add_point(pos + dir * length)
				pos += dir * length
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
