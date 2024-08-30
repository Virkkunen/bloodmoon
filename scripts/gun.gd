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

func shot_anim() -> void:
	var tween : Tween = create_tween()
	var cursor_position = get_global_mouse_position()
	var which_rotation : float

	if cursor_position.x < global_position.x:
		which_rotation = PI / 4
	else:
		which_rotation = -PI / 4

	tween.tween_property(sprite, "rotation", which_rotation, 0.025)
	tween.tween_property(sprite, "rotation", 0, 0.08).set_ease(Tween.EASE_OUT)

func reload_anim(full: bool) -> void:
	var tween : Tween = create_tween()
	var cursor_position = get_global_mouse_position()
	var which_rotation : float
	var hold_time = 1.05

	if cursor_position.x < global_position.x:
		which_rotation = PI / 3
	else:
		which_rotation = -PI / 3

	tween.tween_property(sprite, "rotation", which_rotation, 0.075)
	if full:
		tween.tween_property(sprite, "rotation", 0, 0.08).set_ease(Tween.EASE_OUT).set_delay(hold_time)
		tween.tween_property(sprite, "position", sprite.position - Vector2(2, 0), 0.05).set_ease(Tween.EASE_IN).set_delay(0.5)
		tween.tween_property(sprite, "position", sprite.position, 0.05).set_ease(Tween.EASE_OUT)
	else:
		tween.tween_property(sprite, "rotation", 0, 0.08).set_ease(Tween.EASE_OUT).set_delay(hold_time)

	
