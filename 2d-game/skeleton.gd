extends CharacterBody2D

@export var speed: float = 100.0

var player: CharacterBody2D = null
var chasing: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea


func _ready() -> void:
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)

	if sprite.sprite_frames.has_animation("idle"):
		sprite.play("idle")


func _physics_process(_delta: float) -> void:
	if chasing and is_instance_valid(player):
		var direction = (player.global_position - global_position).normalized()

		velocity = direction * speed
		move_and_slide()

		if sprite.sprite_frames.has_animation("walk"):
			sprite.play("walk")

		# Flip the sprite based on horizontal movement.
		if direction.x != 0:
			sprite.flip_h = direction.x < 0

	else:
		velocity = Vector2.ZERO

		if sprite.sprite_frames.has_animation("idle"):
			sprite.play("idle")


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body as CharacterBody2D
		chasing = true


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player:
		chasing = false
		player = null
