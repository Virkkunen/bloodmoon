extends CharacterBody2D

signal ammo_changed
signal health_changed

@export var speed = 200
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
@onready var damage_cooldown : Timer = $Timers/DamageCooldown
@onready var reload_timer : Timer = $Timers/ReloadTimer
@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D

var can_be_damaged = true
var can_shoot = true
var Bullet : PackedScene = preload("res://scenes/bullet.tscn")

func _ready() -> void:
	ammo = max_ammo
	health = max_health

	# signals
	damage_cooldown.timeout.connect(_on_damage_cooldown_timeout)
	reload_timer.timeout.connect(_on_reload_timer_timeout)

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
	if Input.is_action_just_pressed("shoot") and can_shoot:
		shoot()

	if Input.is_action_just_pressed("reload"):
		reload_timer.start()
		Hud.show_reload_hint("reloading")

func player_hit(damage: float) -> void:
	if can_be_damaged:
		can_be_damaged = false
		health -= damage
		damage_cooldown.start()
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
	if ammo > 0:
		var bullet = Bullet.instantiate() as Area2D
		bullet.position = $Gun/Muzzle.global_position
		bullet.velocity = get_muzzle_direction(bullet) * bullet.speed

		get_parent().add_child(bullet)

		ammo -= 1
	else:
		can_shoot = false

func get_muzzle_direction(bullet: Area2D) -> Vector2:
	var cursor_position = get_global_mouse_position()
	var direction = (cursor_position - bullet.position).normalized()
	return direction

func sprite_colour_on_damage() -> void:
	print("here")
	var tween : Tween = create_tween()
	sprite.modulate = Global.colour03
	tween.tween_property(sprite, "modulate", Color(1, 1, 1), 1.2).set_delay(0.3).set_ease(Tween.EASE_IN)