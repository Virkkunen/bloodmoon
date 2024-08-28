extends CharacterBody2D

@export var speed = 20
@export var radius = 14
@export var health = 150
@export var attack = 25
@export var wander_time : float

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D

var direction = Vector2.ZERO
var time_since_direction_change = 0.0

func _ready() -> void:
	add_to_group("Zombies")
	wander_time = randf_range(5, 45)
	update_flip()
	change_direction()

func _physics_process(delta: float) -> void:
	time_since_direction_change += delta
	if time_since_direction_change >= wander_time:
		change_direction()
		time_since_direction_change = 0

	velocity = direction * speed
	move_and_slide()

	update_animation()
	update_flip()

func update_animation() -> void:
	if velocity.length() > 0:
		sprite.play("walk")
	else:
		sprite.play("idle")

	update_flip()

func update_flip() -> void:
	if velocity.x < 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false

func change_direction() -> void:
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()