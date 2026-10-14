extends Node2D

# Maze dimensions
const ROWS = 25
const COLS = 25
const CELL_SIZE = 20

# Colors
const WALL_COLOR = Color("#333333")
const PATH_COLOR = Color("#eeeeee")

# Maze data
var maze = []

# UI elements
var generate_button: Button

# A container node to group all physical wall collision blocks together
var wall_container: Node2D

func _ready():
	# Create the collision container and add it to the scene tree
	wall_container = Node2D.new()
	add_child(wall_container)
	
	# Setup the scene
	setup_ui()
	
	# Initialize maze array
	initialize_maze()
	
	# Generate initial maze
	generate_maze()
	
	# Force redraw
	queue_redraw()

func setup_ui():
	# Create a generate button
	generate_button = Button.new()
	generate_button.text = "Generate New Maze"
	generate_button.position = Vector2(10, ROWS * CELL_SIZE + 10)
	generate_button.size = Vector2(150, 30)
	generate_button.connect("pressed", Callable(self, "_on_generate_button_pressed"))
	add_child(generate_button)

func initialize_maze():
	# Create a 2D array filled with walls (1)
	maze = []
	for r in range(ROWS):
		var row = []
		for c in range(COLS):
			row.append(1)
		maze.append(row)

func generate_maze():
	# Wipe away any old collision blocks from a previous maze layout
	for child in wall_container.get_children():
		child.queue_free()

	# Reset maze to all walls
	for r in range(ROWS):
		for c in range(COLS):
			maze[r][c] = 1
	
	# Start at position (1,1)
	var start_row = 1
	var start_col = 1
	maze[start_row][start_col] = 0
	
	# Start carving passages
	carve_passages(start_row, start_col)
	
	# Tell the physics engine to spawn collision blocks where your walls are
	create_wall_collisions()

func carve_passages(r, c):
	# Define the four possible directions (up, right, down, left) with a step of 2
	var directions = [
		[-2, 0],  # Up
		[0, 2],   # Right
		[2, 0],   # Down
		[0, -2]   # Left
	]
	
	# Randomize direction order
	directions.shuffle()
	
	# Try each direction
	for direction in directions:
		# 💡 FIXED: Safely added back the index positions [0] and [1] 
		var dr = direction[0]
		var dc = direction[1]
		
		var new_r = r + dr
		var new_c = c + dc
		
		# Check if the new position is valid and still a wall
		if new_r > 0 and new_r < ROWS - 1 and new_c > 0 and new_c < COLS - 1 and maze[new_r][new_c] == 1:
			# Carve passage by making the wall between current and new cell a path
			maze[r + dr/2][c + dc/2] = 0
			# Make the new cell a path
			maze[new_r][new_c] = 0
			# Continue from the new cell
			carve_passages(new_r, new_c)

# This function loops through your grid array and spawns a real collision block for every wall
func create_wall_collisions():
	for r in range(ROWS):
		for c in range(COLS):
			if maze[r][c] == 1: # If this grid slot is a wall
				
				# 1. Create a physical static body
				var static_body = StaticBody2D.new()
				
				# 2. Position it at the center of the grid tile
				static_body.position = Vector2(
					c * CELL_SIZE + CELL_SIZE / 2.0, 
					r * CELL_SIZE + CELL_SIZE / 2.0
				)
				
				# 3. Create a box shape matching the pixel size of your cell
				var collision_shape = CollisionShape2D.new()
				var box_shape = RectangleShape2D.new()
				box_shape.size = Vector2(CELL_SIZE, CELL_SIZE)
				collision_shape.shape = box_shape
				
				# 4. Attach the shape to the body, and put the body in our container
				static_body.add_child(collision_shape)
				wall_container.add_child(static_body)

func _draw():
	# Draw the maze
	for r in range(ROWS):
		for c in range(COLS):
			var color = WALL_COLOR if maze[r][c] == 1 else PATH_COLOR
			var rect = Rect2(c * CELL_SIZE, r * CELL_SIZE, CELL_SIZE, CELL_SIZE)
			draw_rect(rect, color)

func _on_generate_button_pressed():
	# Generate a new maze and redraw
	generate_maze()
	queue_redraw()
