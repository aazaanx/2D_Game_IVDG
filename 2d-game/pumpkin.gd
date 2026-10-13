extends AnimatedSprite2D

@export var speed = 500

func _process(delta):
	if Input.is_key_pressed(KEY_RIGHT):
		position.x += speed * delta
	elif Input.is_key_pressed(KEY_LEFT):
		position.x -= speed * delta
	elif Input.is_key_pressed(KEY_UP):
		position.y -= speed * delta
	elif Input.is_key_pressed(KEY_DOWN):
		position.y += speed * delta
