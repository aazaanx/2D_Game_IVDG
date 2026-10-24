
extends Area2D

var player: Node2D = null
var opened: bool = false

@export var heal_amount: int = 25

@onready var sprite: AnimatedSprite2D = $ChestAnimation


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if sprite.sprite_frames.has_animation("closed"):
		sprite.play("closed")

	print("Chest script is running")


func _process(_delta: float) -> void:
	if opened or not is_instance_valid(player):
		return

	if Input.is_key_pressed(KEY_E):
		if not player.get("has_key"):
			print("The chest is locked! Find the key first.")
			return

		open_chest()


func open_chest() -> void:
	if opened or not is_instance_valid(player):
		return

	opened = true

	if sprite.sprite_frames.has_animation("open"):
		sprite.play("open")

	# Consume the key
	player.set("has_key", false)

	# Give the player a sword
	player.set("has_sword", true)

	# Heal the player using the existing player function
	if player.has_method("heal"):
		player.heal(heal_amount)
	else:
		push_error("Player does not have a heal() function!")

	print("Chest opened! You found a sword and restored up to 25 health!")


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		print("Near chest. Press E to open.")


func _on_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
