
extends Area2D

var player: Node2D = null
var collected: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	print("Key ready")


func _process(_delta: float) -> void:
	if collected or not is_instance_valid(player):
		return

	if Input.is_key_pressed(KEY_E):
		collected = true
		player.set("has_key", true)
		print("Key collected!")
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		print("Player detected! Press E to collect the key.")


func _on_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
