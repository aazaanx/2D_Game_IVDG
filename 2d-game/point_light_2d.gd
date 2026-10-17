extends PointLight2D

func _ready() -> void:
	# 1. Create a new 2D Gradient Texture
	var texture_2d = GradientTexture2D.new()
	
	# 2. Make it a radial (circular) light
	texture_2d.fill = GradientTexture2D.FILL_RADIAL
	
	# 3. Center the light circle
	texture_2d.fill_from = Vector2(0.5, 0.5)
	texture_2d.fill_to = Vector2(0.5, 0.0) # Adjusts the radius
	
	# 4. Create the fade gradient (White in center, Black at edges)
	var new_gradient = Gradient.new()
	new_gradient.set_color(0, Color.WHITE) # Center color (Bright)
	new_gradient.set_color(1, Color.BLACK) # Edge color (Fades to dark)
	
	# 5. Apply the gradient to the texture
	texture_2d.gradient = new_gradient
	
	# 6. Assign the generated circular texture to this light node
	self.texture = texture_2d
	
	# Optional: Turn on shadows automatically via code
	self.shadow_enabled = true
