
extends Area2D

@export var required_coins: int = 10

var is_open: bool = false
var player_nearby: bool = false



func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
@onready var door_sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var message_label: Label = get_node_or_null("Label")

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


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true

		if not is_open and message_label:
			message_label.text = "Collect all 10 coins!"


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false


func update_door() -> void:
	if is_open:
		if door_sprite:
			door_sprite.modulate = Color(0.3, 1.0, 0.3)

		if message_label:
			message_label.text = "Door open! Press E to exit."
	else:
		if door_sprite:
			door_sprite.modulate = Color(1.0, 0.4, 0.4)


func finish_level() -> void:
	get_tree().paused = true

	var layer := CanvasLayer.new()
	layer.layer = 20
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().current_scene.add_child(layer)

	var background := ColorRect.new()
	background.color = Color(0.0, 0.0, 0.0, 0.85)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.process_mode = Node.PROCESS_MODE_ALWAYS
	layer.add_child(background)

	var label := Label.new()
	label.text = "LEVEL COMPLETE!\n\nYou collected all 10 coins!"
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 32)
	label.process_mode = Node.PROCESS_MODE_ALWAYS
	background.add_child(label)
