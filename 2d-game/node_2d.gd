
extends Node2D

# Maze dimensions
const ROWS = 25
const COLS = 25
const CELL_SIZE = 20

# Colors
const WALL_COLOR = Color("#333333")
const PATH_COLOR = Color("#eeeeee")
const GOAL_COLOR = Color("#22cc66")

# Main game scene
const MAIN_SCENE = "res://block_maze.tscn"

# Maze data
var maze = []

# UI elements
var generate_button: Button

# Container for physical wall collision blocks
var wall_container: Node2D

# Tutorial goal
var goal: Area2D


func _ready():
	# Create the collision container
	wall_container = Node2D.new()
	add_child(wall_container)

	# Setup the scene


	# Initialize maze array
	initialize_maze()

	# Generate initial maze
	generate_maze()

	# Create the tutorial goal
	setup_goal()

	# Force redraw
	queue_redraw()



func initialize_maze():
	maze = []

	for r in range(ROWS):
		var row = []

		for c in range(COLS):
			row.append(1)

		maze.append(row)


func generate_maze():
	# Remove old wall collision blocks
	for child in wall_container.get_children():
		child.free()

	# Reset maze
	for r in range(ROWS):
		for c in range(COLS):
			maze[r][c] = 1

	# Start position
	var start_row = 1
	var start_col = 1
	maze[start_row][start_col] = 0

	# Carve passages
	carve_passages(start_row, start_col)

	# Ensure goal is walkable and connected
	var goal_row = ROWS - 2
	var goal_col = COLS - 2

	maze[goal_row][goal_col] = 0
	maze[goal_row][goal_col - 1] = 0

	# Create wall collisions
	create_wall_collisions()


func carve_passages(r, c):
	var directions = [
		[-2, 0],
		[0, 2],
		[2, 0],
		[0, -2]
	]

	directions.shuffle()

	for direction in directions:
		var dr = direction[0]
		var dc = direction[1]

		var new_r = r + dr
		var new_c = c + dc

		if (
			new_r > 0
			and new_r < ROWS - 1
			and new_c > 0
			and new_c < COLS - 1
			and maze[new_r][new_c] == 1
		):
			maze[r + int(dr / 2)][c + int(dc / 2)] = 0
			maze[new_r][new_c] = 0

			carve_passages(new_r, new_c)


func create_wall_collisions():
	for r in range(ROWS):
		for c in range(COLS):
			if maze[r][c] == 1:
				var static_body = StaticBody2D.new()

				static_body.position = Vector2(
					c * CELL_SIZE + CELL_SIZE / 2.0,
					r * CELL_SIZE + CELL_SIZE / 2.0
				)

				var collision_shape = CollisionShape2D.new()
				var box_shape = RectangleShape2D.new()

				box_shape.size = Vector2(
					CELL_SIZE,
					CELL_SIZE
				)

				collision_shape.shape = box_shape
				static_body.add_child(collision_shape)
				wall_container.add_child(static_body)


# =========================================
# TUTORIAL GOAL
# =========================================

func setup_goal():
	if is_instance_valid(goal):
		goal.queue_free()

	goal = Area2D.new()
	goal.name = "TutorialGoal"

	# Bottom-right goal cell
	goal.position = Vector2(
		(COLS - 2) * CELL_SIZE + CELL_SIZE / 2.0,
		(ROWS - 2) * CELL_SIZE + CELL_SIZE / 2.0
	)

	# Detect bodies on collision layer 1
	goal.collision_layer = 0
	goal.collision_mask = 1
	goal.monitoring = true

	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(18, 18)

	collision.shape = shape
	goal.add_child(collision)
	add_child(goal)

	goal.body_entered.connect(_on_goal_body_entered)


func _on_goal_body_entered(body: Node2D):
	print("Goal touched by: ", body.name)

	# Player node must be named Player
	if body.name != "player":
		return

	print("Tutorial completed! Loading main game...")

	# Defer scene change to avoid physics callback issues
	get_tree().call_deferred(
		"change_scene_to_file",
		MAIN_SCENE
	)


# =========================================
# DRAW MAZE
# =========================================

func _draw():
	for r in range(ROWS):
		for c in range(COLS):
			var color = (
				WALL_COLOR
				if maze[r][c] == 1
				else PATH_COLOR
			)

			var rect = Rect2(
				c * CELL_SIZE,
				r * CELL_SIZE,
				CELL_SIZE,
				CELL_SIZE
			)

			draw_rect(rect, color)

	# Draw green goal marker
	draw_rect(
		Rect2(
			(COLS - 2) * CELL_SIZE + 4,
			(ROWS - 2) * CELL_SIZE + 4,
			CELL_SIZE - 8,
			CELL_SIZE - 8
		),
		GOAL_COLOR
	)


func _on_generate_button_pressed():
	generate_maze()
	queue_redraw()
