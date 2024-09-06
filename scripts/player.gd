extends CharacterBody2D

enum States {IDLE, WALKING, DEATH, SHOOTING, RELOADING}

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

@export var state : States = States.IDLE : set = set_state
@export var gun_state : States = States.IDLE : set = set_gun_state

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
@onready var area_shot : Area2D = $ShotArea

var can_be_damaged = true
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
		$"../HUD/DEBUG/can_reload".text = "STATE: " + str(state)
		$"../HUD/DEBUG/can_shoot".text = "GUN STATE: " + str(gun_state)
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
	if velocity.length() > 0:
		set_state(States.WALKING)
	else:
		set_state(States.IDLE)

	# shooting
	if Input.is_action_just_pressed("shoot"):
		shoot()

	if Input.is_action_just_pressed("reload"):
		reload()

func set_state(new_state: States) -> void:
	# var previous_state = state
	state = new_state

	if state in [States.WALKING]:
		sprite.play("walk")
	elif state == States.IDLE:
		sprite.play("idle")

func set_gun_state(new_state: States) -> void:
	# var previous_state = gun_state
	gun_state = new_state

func player_hit(damage: float) -> void:
	if can_be_damaged:
		can_be_damaged = false
		health -= damage
		timer_damage_cooldown.start()
		sprite_colour_on_damage()

func _on_damage_cooldown_timeout() -> void:
	can_be_damaged = true

func reload() -> void:
	if gun_state == States.SHOOTING:
		return

	set_gun_state(States.RELOADING)

	# can_reload = false
	# can_shoot = false
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
	set_gun_state(States.IDLE)
	# can_shoot = true
	# can_reload = true
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
	# remove
	tween.finished.connect(self.queue_free)
	emit_signal("player_dead")

func update_animation() -> void:
	# sprite.play("walk") if velocity.length() > 0 else sprite.play("idle")
	
	var cursor_position = get_global_mouse_position()
	sprite.flip_h = true if cursor_position.x < position.x else false

func shoot() -> void:
	if ammo > 0 and gun_state == States.IDLE:
		set_gun_state(States.SHOOTING)
		random_sound(sound_shot01)
		gun.shot_anim()
		timer_shot_delay.start()
		var bullet = Bullet.instantiate() as Area2D
		bullet.position = $Gun/Muzzle.global_position
		bullet.velocity = get_muzzle_direction(bullet) * bullet.speed
		get_parent().add_child(bullet)
		ammo -= 1

		area_shot.monitorable = true
		area_shot.monitoring = true
		await get_tree().create_timer(0.1).timeout
		area_shot.monitorable = false
		area_shot.monitoring = false

	elif ammo <= 0 and not sound_shot_empty.playing and gun_state == States.IDLE:
		sound_shot_empty.play()

func _on_shot_delay_timeout() -> void:
	# can_shoot = true if ammo > 0 and not can_shoot else false
	if ammo >= 0:
		set_gun_state(States.IDLE)

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