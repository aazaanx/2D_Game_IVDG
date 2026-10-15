extends CharacterBody2D

const speed = 200
var current_dir = "none"

func _ready() -> void:
	$AnimatedSprite2D.play("front_idle") # Note: Check if this matches "idle_front" below!

func _physics_process(delta: float) -> void:
	player_movement(delta)

func player_movement(delta: float) -> void:
	var input_vector = Vector2.ZERO
	
	# Get inputs cleanly
	if Input.is_action_pressed("ui_right"):
		input_vector.x = 1
		current_dir = "right"
	elif Input.is_action_pressed("ui_left"):
		input_vector.x = -1
		current_dir = "left"
		
	if Input.is_action_pressed("ui_up"):
		input_vector.y = -1
		current_dir = "up"
	elif Input.is_action_pressed("ui_down"):
		input_vector.y = 1
		current_dir = "down"
	
	# Apply velocity
	if input_vector != Vector2.ZERO:
		velocity = input_vector.normalized() * speed
		player_animation(1)
	else:
		velocity = Vector2.ZERO
		player_animation(0)
	
	move_and_slide()
	
func player_animation(movement: int) -> void:
	var animation = $AnimatedSprite2D
	
	if current_dir == "right":
		animation.flip_h = false
		animation.play("walk_side" if movement == 1 else "idle_side")
			
	elif current_dir == "left":
		animation.flip_h = true
		animation.play("walk_side" if movement == 1 else "idle_side")
			
	elif current_dir == "up":
		animation.flip_h = false # Typically back animations don't need horizontal flipping
		animation.play("walk_back" if movement == 1 else "idle_back")
			
	elif current_dir == "down":
		animation.flip_h = false # Typically front animations don't need horizontal flipping
		animation.play("walk_front" if movement == 1 else "idle_front")

# Transition detection functions
func _on_cliff_side_transition_body_entered(body: Node2D) -> void:
	print("Entered: ", body.name)

func _on_cliff_side_transition_body_exited(body: Node2D) -> void:
	print("Exited: ", body.name)
