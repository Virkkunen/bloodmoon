extends CharacterBody2D

signal zombie_killed

@export var speed = 20.0
@export var max_health = 150.0
@export var health : float :
	get:
		return health
	set(value):
		health = value
		if health <= 0:
			emit_signal("zombie_killed", self)
			if Global.zombies.has(self):
				Global.zombies.erase(self)
			Global.score += 1
			queue_free()
@export var max_damage = 25.0
@export var damage : float
@export var wander_time : float

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D

var direction = Vector2.ZERO
var time_since_direction_change = 0.0

func _ready() -> void:
	add_to_group("Zombies")
	health = randf_range(max_health - 0.2 * max_health, max_health)
	damage = randf_range(max_damage - 0.2 * max_damage, max_damage)
	wander_time = randf_range(5, 45)
	change_direction()

func _physics_process(delta: float) -> void:
	time_since_direction_change += delta
	if time_since_direction_change >= wander_time:
		change_direction()
		time_since_direction_change = 0

	velocity = direction * speed
	move_and_slide()

	update_animation()

func update_animation() -> void:
	if velocity.length() > 0:
		sprite.play("walk")
	else:
		sprite.play("idle")

	# update_flip()
	if velocity.x < 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false

func change_direction() -> void:
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()

func sprite_colour_on_damage() -> void:
	var tween : Tween = create_tween()
	sprite.modulate = Global.colour03
	tween.tween_property(sprite, "modulate", Color(1, 1, 1), 0.3).set_ease(Tween.EASE_IN)

func get_hit(incoming_damage: float) -> void:
	sprite_colour_on_damage()
	health -= incoming_damage