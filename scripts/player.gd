extends CharacterBody2D

signal ammo_changed
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
@onready var sprite_gun : Sprite2D = $Gun/GunSprite
@onready var gun : CanvasGroup = $Gun
@onready var timer_shot_delay : Timer = $Timers/ShotDelay
@onready var sound_reload_partial : AudioStreamPlayer2D = $Sounds/ReloadPartialSound
@onready var sound_reload_full : AudioStreamPlayer2D = $Sounds/ReloadFullSound
@onready var sound_shot01 : AudioStreamPlayer2D = $Sounds/Shot01
@onready var sound_shot_empty : AudioStreamPlayer2D = $Sounds/ShotEmpty
@onready var camera : Camera2D = $Camera2D
@onready var area_footsteps : Area2D = $Footsteps

var can_be_damaged = true
var can_shoot = true
var can_reload = true
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

	if Global.debug:
		$"../HUD/DEBUG".visible = true
		$"../HUD/DEBUG/can_reload".text = "can_reload: " + str(can_reload)
		$"../HUD/DEBUG/can_shoot".text = "can_shoot: " + str(can_shoot)
		$"../HUD/DEBUG/reload_partial".text = "reload_partial: " + str(timer_reload_partial.time_left)
		$"../HUD/DEBUG/reload_full".text = "reload_full: " + str(timer_reload_full.time_left)
		$"../HUD/DEBUG/health".text = "health: " + str(health)

	# collision
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var body := collision.get_collider()
		if body.is_in_group("Zombies"):
			player_hit(body.damage)

	if velocity != Vector2.ZERO:
		Global.player_position = position

func get_input() -> void:
	# movement
	var input_dir = Input.get_vector("left", "right", "up", "down")
	velocity = input_dir * speed

	# shooting
	if Input.is_action_just_pressed("shoot"):
		shoot()

	if Input.is_action_just_pressed("reload"):
		reload()


func player_hit(damage: float) -> void:
	if can_be_damaged:
		can_be_damaged = false
		health -= damage
		timer_damage_cooldown.start()
		sprite_colour_on_damage()

func _on_damage_cooldown_timeout() -> void:
	can_be_damaged = true

func reload() -> void:
	if not can_reload:
		return

	can_reload = false
	can_shoot = false
	timer_shot_delay.stop()

	if ammo > 0:
		timer_reload_partial.start()
		sound_reload_partial.play()
		gun.reload_anim(false)
	else:
		timer_reload_full.start()
		sound_reload_full.play()
		gun.reload_anim(true)

	Hud.show_reload_hint("reloading")

func _on_reload_timer_timeout() -> void:
	can_shoot = true
	can_reload = true
	ammo = max_ammo
	Hud.ammo_bar.indeterminate = false

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
	# tween.parallel().tween_property(camera, "zoom", Vector2(1, 1), 0.6).set_delay(0.5).set_ease(Tween.EASE_IN)
	# remove
	tween.finished.connect(self.queue_free)
	emit_signal("player_dead")

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
		random_sound(sound_shot01)
		gun.shot_anim()
		timer_shot_delay.start()
		var bullet = Bullet.instantiate() as Area2D
		bullet.position = $Gun/Muzzle.global_position
		bullet.velocity = get_muzzle_direction(bullet) * bullet.speed
		get_parent().add_child(bullet)
		ammo -= 1
		can_shoot = false

	elif ammo <= 0 and not sound_shot_empty.playing and can_reload:
		sound_shot_empty.play()

func _on_shot_delay_timeout() -> void:
	if ammo > 0 and not can_shoot:
		can_shoot = true

func get_muzzle_direction(bullet: Area2D) -> Vector2:
	var cursor_position = get_global_mouse_position()
	var direction = (cursor_position - bullet.position).normalized()
	return direction

func sprite_colour_on_damage() -> void:
	var tween : Tween = create_tween()
	sprite.modulate = Global.colour03
	tween.tween_property(sprite, "modulate", Color(1, 1, 1), 1.2).set_delay(0.3).set_ease(Tween.EASE_IN)

func random_sound(sound: AudioStreamPlayer2D) -> void:
	sound.pitch_scale = randf_range(0.8, 1.05)
	sound.volume_db = randf_range(-1.2, 1.4)
	sound.play()