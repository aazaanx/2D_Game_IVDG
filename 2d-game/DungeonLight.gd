
extends PointLight2D

@export var light_color: Color = Color(1.0, 0.88, 0.65, 1.0)
@export_range(0.1, 3.0, 0.1) var light_energy: float = 1.2
@export_range(0.2, 4.0, 0.1) var light_size: float = 1.5

@export var flicker: bool = false
@export_range(0.0, 0.5, 0.01) var flicker_amount: float = 0.08
@export_range(0.1, 20.0, 0.1) var flicker_speed: float = 5.0

var flicker_time: float = 0.0


func _ready() -> void:
	color = light_color
	energy = light_energy
	texture_scale = light_size

	# Create a soft white light fading to transparent.
	var gradient := Gradient.new()
	gradient.set_color(0, Color.WHITE)
	gradient.set_color(1, Color(1, 1, 1, 0))

	var light_texture := GradientTexture2D.new()
	light_texture.gradient = gradient
	light_texture.fill = GradientTexture2D.FILL_RADIAL
	light_texture.fill_from = Vector2(0.5, 0.5)
	light_texture.fill_to = Vector2(1.0, 0.5)
	light_texture.width = 256
	light_texture.height = 256

	texture = light_texture

	# Start without wall shadows.
	shadow_enabled = false


func _process(delta: float) -> void:
	if flicker:
		flicker_time += delta * flicker_speed
		energy = light_energy + sin(flicker_time) * flicker_amount
	else:
		energy = light_energy
