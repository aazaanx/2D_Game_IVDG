
extends CharacterBody2D

@export var speed: float = 50.0
@export var max_health: int = 100
@export var attack_damage: int = 15
@export var attack_range: float = 38.0
@export var attack_cooldown: float = 1.0

var current_health: int = 100
var attack_timer: float = 0.0
var player: CharacterBody2D = null
var is_dead: bool = false

@onready var sprite: AnimatedSprite2D = $Skeleton
@onready var detection_area: Area2D = $DetectionArea
@onready var health_bar: ProgressBar = $HealthBar


func _ready() -> void:
	print("MONSTER SCRIPT STARTED: ", get_path())

	add_to_group("monster")

	current_health = max_health
	health_bar.max_value = max_health
	health_bar.value = current_health

	detection_area.monitoring = true

	if not detection_area.body_entered.is_connected(_on_body_entered):
		detection_area.body_entered.connect(_on_body_entered)

	if not detection_area.body_exited.is_connected(_on_body_exited):
		detection_area.body_exited.connect(_on_body_exited)

	print("DetectionArea monitoring: ", detection_area.monitoring)
	print("DetectionArea collision mask: ", detection_area.collision_mask)

	play_idle()


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	attack_timer = maxf(0.0, attack_timer - delta)

	if not is_instance_valid(player):
		velocity = Vector2.ZERO
		move_and_slide()
		play_idle()
		return

	var offset: Vector2 = player.global_position - global_position
	var distance: float = offset.length()

	if distance <= attack_range:
		velocity = Vector2.ZERO
		move_and_slide()
		play_idle()
		attack_player()
		return

	# Direction points from the monster toward the player.
	var direction: Vector2 = offset.normalized()
	velocity = direction * speed
	move_and_slide()

	print("CHASE: direction=", direction,
		" | velocity=", velocity,
		" | monster=", global_position,
		" | player=", player.global_position)

	if velocity.x < 0.0:
		sprite.flip_h = true
	elif velocity.x > 0.0:
		sprite.flip_h = false

	if sprite.sprite_frames.has_animation("walk"):
		if sprite.animation != "walk":
			sprite.play("walk")


func play_idle() -> void:
	if sprite.sprite_frames.has_animation("idle"):
		if sprite.animation != "idle":
			sprite.play("idle")



func _on_body_entered(body: Node2D) -> void:
	if body == self:
		return

	if body is TileMapLayer:
		return

	if body is CharacterBody2D and body.is_in_group("player"):
		player = body as CharacterBody2D
		print("PLAYER TARGET LOCKED: ", player.get_path())
		print("Monster position: ", global_position)
		print("Player position: ", player.global_position)



func _on_body_exited(body: Node2D) -> void:
	print("DETECTION SIGNAL: body exited = ", body.name)

	if body == player:
		player = null
		velocity = Vector2.ZERO
		play_idle()
		print("PLAYER LEFT DETECTION AREA")


func attack_player() -> void:
	if attack_timer > 0.0:
		return

	if not is_instance_valid(player):
		return

	attack_timer = attack_cooldown

	if player.has_method("take_damage"):
		player.take_damage(attack_damage)
		print("Monster hit player for ", attack_damage, " damage!")


func take_damage(amount: int) -> void:
	if is_dead:
		return

	current_health = maxi(0, current_health - amount)
	health_bar.value = current_health

	print("Monster health: ", current_health, "/", max_health)

	if current_health <= 0:
		die()


func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	queue_free()
