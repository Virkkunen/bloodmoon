extends CharacterBody2D

enum States {IDLE, WALKING, DEATH}

signal health_changed
signal player_dead

@export var speed = 200.0
@export var max_health = 100.0
@export var health : float = max_health :
	get:
		return health
	set(value):
		health = value
		emit_signal("health_changed", health)
		if health <= 0:
			player_death()
			pass

@export var state : States = States.IDLE : set = set_state

# @onready var hitbox : CollisionPolygon2D = $Hitbox
@onready var Hud : CanvasLayer = $"../HUD"
@onready var timer_damage_cooldown : Timer = $Timers/DamageCooldown

@onready var sprite : AnimatedSprite2D = $sprite
@onready var gun : Node2D = $Gun

@onready var camera : Camera2D = $Camera2D
@onready var area_shot : Area2D = $ShotArea

var can_be_damaged = true

func _ready() -> void:
	health = max_health

	# signals
	timer_damage_cooldown.timeout.connect(_on_damage_cooldown_timeout)


func _physics_process(_delta: float) -> void:
	get_input()
	move_and_slide()
	update_animation()

	$"../HUD/DEBUG/health".text = "health: " + str(health) if Global.debug else ""

	# collision
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var body := collision.get_collider()
		if body.is_in_group("Zombies"):
			player_hit(body.damage)

	if state == States.WALKING:
		Global.player_position = position

func get_input() -> void:
	# movement
	var input_dir = Input.get_vector("left", "right", "up", "down")
	velocity = input_dir * speed
	if velocity.length() > 0:
		set_state(States.WALKING)
	else:
		set_state(States.IDLE)

	# shooting
	if Input.is_action_pressed("shoot"):
		gun.shoot()

	if Input.is_action_just_pressed("reload"):
		gun.reload()

func set_state(new_state: States) -> void:
	# var previous_state = state
	state = new_state

	if state == States.WALKING:
		sprite.play("walk")
	elif state == States.IDLE:
		sprite.play("idle")

func player_hit(damage: float) -> void:
	if can_be_damaged:
		can_be_damaged = false
		health -= damage
		timer_damage_cooldown.start()
		sprite_colour_on_damage()

func _on_damage_cooldown_timeout() -> void:
	can_be_damaged = true

func player_death() -> void:
	# stop physics
	set_physics_process(false)
	gun.set_physics_process(false)
	collision_layer = 0
	collision_mask = 0
	sprite.play("idle")

	# animation
	var tween : Tween = create_tween()
	tween.tween_property(sprite, "modulate", Global.colour03, 0.2).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(sprite, "rotation_degrees", 90, 0.1).set_ease(Tween.EASE_IN)
	tween.tween_property(sprite, "modulate", Color(0, 0, 0, 0), 0.3).set_delay(2)
	# remove
	tween.finished.connect(self.queue_free)
	emit_signal("player_dead")

func update_animation() -> void:
	var cursor_position = get_global_mouse_position()
	sprite.flip_h = true if cursor_position.x < position.x else false

func sprite_colour_on_damage() -> void:
	var tween : Tween = create_tween()
	sprite.modulate = Global.colour03
	tween.tween_property(sprite, "modulate", Color(1, 1, 1), 1.2).set_delay(0.3).set_ease(Tween.EASE_IN)

func add_ammo(mag_count: int) -> void:
	gun.mag_count += mag_count

func change_gun(scene: String) -> void:
	print(scene)
	var new_gun_scene : PackedScene = load(scene)
	gun.queue_free()
	var new_gun = new_gun_scene.instantiate()
	add_child(new_gun)
	gun = new_gun
	Hud.Gun = gun
	print(gun)


# func random_sound(sound: AudioStreamPlayer2D) -> void:
# 	sound.pitch_scale = randf_range(0.8, 1.05)
# 	sound.volume_db = randf_range(-1.2, 1.4)
# 	sound.play()
