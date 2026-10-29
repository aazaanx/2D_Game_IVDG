
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

	var coins_collected = player.get("collected_coins")

	if coins_collected == null:
		return

	if coins_collected >= required_coins and not is_open:
		is_open = true
		update_door()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true

		var coins_collected = body.get("collected_coins")

		if coins_collected != null and coins_collected >= required_coins:
			is_open = true
			update_door()
			get_tree().change_scene_to_file("res://lastlevel.tscn")
		else:
			if message_label:
				message_label.text = "You need %d more coins!" % (
					required_coins - (coins_collected if coins_collected != null else 0)
				)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false


func update_door() -> void:
	if is_open:
		if door_sprite:
			door_sprite.modulate = Color(0.3, 1.0, 0.3)

		if message_label:
			message_label.text = "Door open!"
	else:
		if door_sprite:
			door_sprite.modulate = Color(1.0, 0.4, 0.4)

		if message_label:
			message_label.text = "Collect all 10 coins!"
