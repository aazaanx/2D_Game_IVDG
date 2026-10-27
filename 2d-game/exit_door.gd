
<<<<<<< HEAD
=======
extends Area2D

@export var required_coins: int = 10

var is_open: bool = false
var player_nearby: bool = false

@onready var door_sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var message_label: Label = get_node_or_null("Label")

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if message_label:
		message_label.text = "Collect all 10 coins!"

	update_door()


func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")

	if player == null:
		return

	var coins_collected: int = player.get("collected_coins")

	if coins_collected >= required_coins and not is_open:
		is_open = true
		update_door()

	if player_nearby and Input.is_action_just_pressed("interact"):
		if is_open:
			finish_level()
		elif message_label:
			message_label.text = "You need %d more coins!" % (
				required_coins - coins_collected
			)

>>>>>>> 238a0cbf287cd92af0902d863c4204afbfe98c3e

func _on_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
