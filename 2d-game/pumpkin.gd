extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
var number = 0
@export var speed = 150  

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_D):
		position.x += speed * delta
	if Input.is_key_pressed(KEY_A):
		position.x -= speed * delta
	if Input.is_key_pressed(KEY_S):
		position.y += speed * delta
	if Input.is_key_pressed(KEY_W):
		position.y -= speed * delta 
