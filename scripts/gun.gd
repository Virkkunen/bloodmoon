extends CanvasGroup

@onready var sprite : Sprite2D = $GunSprite

func _physics_process(_delta: float) -> void:
	camera_rotation()

func camera_rotation() -> void:
		var cursor_position = get_global_mouse_position()
		var direction = cursor_position - global_position
		rotation = lerp_angle(rotation, direction.angle(), 0.15) # smooth rotation

		if cursor_position.x < global_position.x:
			sprite.flip_v = true
		else:
			sprite.flip_v = false