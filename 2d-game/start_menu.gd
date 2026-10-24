
extends Control

@export var game_scene: String = "res://maingame.tscn"


func _ready() -> void:
	var start_button = find_child("StartGameButton", true, false) as Button

	if start_button == null:
		push_error("Could not find StartGameButton. Check the button's name in the scene tree.")
		return

	start_button.pressed.connect(_on_start_game_pressed)
	start_button.grab_focus()


func _on_start_game_pressed() -> void:
	var error = get_tree().change_scene_to_file(game_scene)

	if error != OK:
		push_error("Could not load game scene: " + game_scene)



	
