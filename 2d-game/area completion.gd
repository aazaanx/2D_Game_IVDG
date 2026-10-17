extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_goal_body_entered(body: Node2D):
	if body is CharacterBody2D and body.name == "player":
		get_tree().change_scene_to_file("res://block_maze.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
