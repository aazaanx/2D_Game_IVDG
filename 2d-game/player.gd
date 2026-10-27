
extends CharacterBody2D

const speed = 200

@export var max_health: int = 100
@export var attack_damage: int = 25
@export var attack_range: float = 55.0
@export var attack_cooldown: float = 0.75

var current_dir = "none"
var current_health: int = 100
var attack_timer: float = 0.0
var is_dead: bool = false

# COIN SYSTEM
var collected_coins: int = 0
var total_coins: int = 0
var coin_label: Label

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $HealthBar


func _ready() -> void:
	add_to_group("player")

	current_health = max_health
	health_bar.max_value = max_health
	health_bar.value = current_health

	animation.play("idle_side")

	call_deferred("count_coins")


# COIN COUNTER SETUP
func count_coins() -> void:
	total_coins = get_tree().get_nodes_in_group("coins").size()

	var scene = get_tree().current_scene
	coin_label = scene.get_node_or_null("CoinUI/CoinLabel") as Label

	if coin_label == null:
		push_error("CoinLabel not found! Check CoinUI/CoinLabel node names.")
		return

	update_coin_counter()

	print("Total coins in level: ", total_coins)


func update_coin_counter() -> void:
	if is_instance_valid(coin_label):
		coin_label.text = "Coins: " + str(collected_coins) + "/" + str(total_coins)


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	attack_timer = maxf(0.0, attack_timer - delta)

	player_movement()

	if Input.is_action_just_pressed("attack"):
		attack()


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


func attack() -> void:
	if attack_timer > 0.0:
		return

	attack_timer = attack_cooldown

	for enemy in get_tree().get_nodes_in_group("monster"):
		if not is_instance_valid(enemy):
			continue

		if not enemy.has_method("take_damage"):
			continue

		var distance: float = global_position.distance_to(
			enemy.global_position
		)

		# Attack monsters in any direction within range.
		if distance <= attack_range:
			enemy.take_damage(attack_damage)


func take_damage(amount: int) -> void:
	if is_dead:
		return

	current_health = maxi(0, current_health - amount)
	health_bar.value = current_health

	print("Player health: ", current_health, "/", max_health)

	if current_health <= 0:
		die()


# CHEST HEALTH REWARD
func heal(amount: int) -> void:
	if is_dead:
		return

	current_health = mini(max_health, current_health + amount)
	health_bar.value = current_health

	print("Player healed! Health: ", current_health, "/", max_health)


# COIN COLLECTION
func collect_coin() -> void:
	collected_coins += 1

	update_coin_counter()

	print("Coins collected: ", collected_coins, "/", total_coins)

	if collected_coins >= 10:
		print("All 10 coins collected! The exit can open!")


func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	set_physics_process(false)
	show_game_over()


func show_game_over() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 10
	get_tree().current_scene.add_child(layer)

	var background := ColorRect.new()
	background.color = Color(0.0, 0.0, 0.0, 0.8)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(background)

	var label := Label.new()
	label.text = "GAME OVER\n\nPress R to restart"
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 36)
	background.add_child(label)


func _input(event: InputEvent) -> void:
	if is_dead and event is InputEventKey:
		if event.pressed and not event.echo and event.keycode == KEY_R:
			get_tree().reload_current_scene()
