
extends CharacterBody2D

const speed = 200
var current_dir = "none"

func _ready() -> void:
	$AnimatedSprite2D.play("idle_side")

func _physics_process(_delta: float) -> void:
	player_movement()

func player_movement() -> void:
	var input_vector = Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		input_vector.x += 1
		current_dir = "right"

	if Input.is_action_pressed("ui_left"):
		input_vector.x -= 1
		current_dir = "left"

	if Input.is_action_pressed("ui_up"):
		input_vector.y -= 1
		current_dir = "up"

	if Input.is_action_pressed("ui_down"):
		input_vector.y += 1
		current_dir = "down"

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
		animation.flip_h = false
		animation.play("walk_side" if movement == 1 else "idle_side")

	elif current_dir == "down":
		animation.flip_h = false
		animation.play("walk_side" if movement == 1 else "idle_side")
