
extends Area2D

var player: Node2D = null
var collected: bool = false

@export var heal_amount: int = 25

func _ready() -> void:
	add_to_group("coins")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(_delta: float) -> void:
	if collected:
		return

	if not is_instance_valid(player):
		return

	# Collect only when E is pressed
	if Input.is_action_just_pressed("interact"):
		collected = true

		# Update coin counter
		if player.has_method("collect_coin"):
			player.collect_coin()
			print("Coin collected!")
		else:
			push_error("Player has no collect_coin() method!")

		# Heal player
		if player.has_method("heal"):
			player.heal(heal_amount)
		else:
			push_error("Player has no heal() method!")

		# Remove coin after collecting
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		print("Player detected! Press E to collect the coin.")


func _on_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
