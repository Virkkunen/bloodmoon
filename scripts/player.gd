extends CharacterBody2D

signal ammo_changed
signal health_changed

@export var speed = 200.0
@export var max_health = 100.0
@export var health : float :
	get:
		return health
	set(value):
		health = value
		emit_signal("health_changed", health)
@export var max_ammo = 12
@export var ammo : int :
	get:
		return ammo
	set(value):
		ammo = value
		emit_signal("ammo_changed", ammo)

# @onready var hitbox : CollisionPolygon2D = $Hitbox
@onready var Hud : CanvasLayer = $"../HUD"
@onready var timer_damage_cooldown : Timer = $Timers/DamageCooldown
@onready var timer_reload_full : Timer = $Timers/ReloadFullTimer
@onready var timer_reload_partial : Timer = $Timers/ReloadPartialTimer
@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var timer_shot_delay : Timer = $Timers/ShotDelay
@onready var sound_reload_partial : AudioStreamPlayer2D = $Sounds/ReloadPartialSound
@onready var sound_reload_full : AudioStreamPlayer2D = $Sounds/ReloadFullSound
@onready var sound_shot01 : AudioStreamPlayer2D = $Sounds/Shot01
@onready var sound_shot_empty : AudioStreamPlayer2D = $Sounds/ShotEmpty

var can_be_damaged = true
var can_shoot = true
var Bullet : PackedScene = preload("res://scenes/bullet.tscn")

func _ready() -> void:
	ammo = max_ammo
	health = max_health

	# signals
	timer_damage_cooldown.timeout.connect(_on_damage_cooldown_timeout)
	timer_reload_full.timeout.connect(_on_reload_timer_timeout)
	timer_reload_partial.timeout.connect(_on_reload_timer_timeout)
	timer_shot_delay.timeout.connect(_on_shot_delay_timeout)

func _physics_process(_delta: float) -> void:
	get_input()
	move_and_slide()
	update_animation()

	# collision
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var body := collision.get_collider()
		if body.is_in_group("Zombies"):
			player_hit(body.attack)

func get_input() -> void:
	# movement
	var input_dir = Input.get_vector("left", "right", "up", "down")
	velocity = input_dir * speed

	# shooting
	if Input.is_action_just_pressed("shoot"):
		shoot()

	if Input.is_action_just_pressed("reload"):
		if ammo > 0:
			timer_reload_partial.start()
			sound_reload_partial.play()
		elif ammo <= 0:
			timer_reload_full.start()
			sound_reload_full.play()
		Hud.show_reload_hint("reloading")

func player_hit(damage: float) -> void:
	if can_be_damaged:
		can_be_damaged = false
		health -= damage
		timer_damage_cooldown.start()
		sprite_colour_on_damage()

func _on_damage_cooldown_timeout() -> void:
	can_be_damaged = true

func _on_reload_timer_timeout() -> void:
	can_shoot = true
	ammo = max_ammo
	Hud.ammo_bar.indeterminate = false

func player_death() -> void:
	pass

func update_animation() -> void:
	if velocity.length() > 0:
		sprite.play("walk")
	else:
		sprite.play("idle")

	var cursor_position = get_global_mouse_position()
	if cursor_position.x > position.x:
		sprite.flip_h = false
	elif cursor_position.x < position.x:
		sprite.flip_h = true

func shoot() -> void:
	if ammo > 0 and can_shoot:
		sound_shot01.play()
		timer_shot_delay.start()
		can_shoot = false
		var bullet = Bullet.instantiate() as Area2D
		bullet.position = $Gun/Muzzle.global_position
		bullet.velocity = get_muzzle_direction(bullet) * bullet.speed

		get_parent().add_child(bullet)

		ammo -= 1
	elif ammo <= 0:
		if not sound_shot_empty.playing:
			sound_shot_empty.play()
		can_shoot = false

func _on_shot_delay_timeout() -> void:
	if ammo > 0:
		can_shoot = true

func get_muzzle_direction(bullet: Area2D) -> Vector2:
	var cursor_position = get_global_mouse_position()
	var direction = (cursor_position - bullet.position).normalized()
	return direction

func sprite_colour_on_damage() -> void:
	var tween : Tween = create_tween()
	sprite.modulate = Global.colour03
	tween.tween_property(sprite, "modulate", Color(1, 1, 1), 1.2).set_delay(0.3).set_ease(Tween.EASE_IN)