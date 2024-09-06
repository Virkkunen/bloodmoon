extends Node2D

signal gun_state
signal gun_type_signal
signal ammo_changed
signal mag_changed

enum States {IDLE, SHOOTING, RELOADINGPARTIAL, RELOADINGFULL, EMPTY}
enum GunType {PISTOL, REVOLVER, SMG, SHOTGUN, AR}

@export var state : States = States.IDLE : set = set_state
@export var gun_type : GunType = GunType.PISTOL : set = set_gun_type
# gun properties
@export var mag_count : int : 
	get:
		return mag_count
	set(value):
		mag_count = value
		emit_signal("mag_changed", mag_count)
@export var mag_size : int
@export var ammo : int :
	get:
		return ammo
	set(value):
		ammo = value
		emit_signal("ammo_changed", ammo, mag_count)
		if ammo == 0:
			set_state(States.EMPTY)
@export var damage : float
@export var bullet_speed : float
@export var shot_delay : float
@export var full_reload_duration : float
@export var partial_reload_duration : float

@onready var sprite : Sprite2D = $GunSprite
@onready var muzzle : Marker2D = $Muzzle
@onready var sound_reload_partial : AudioStreamPlayer2D = $Sounds/ReloadPartialSound
@onready var sound_reload_full : AudioStreamPlayer2D = $Sounds/ReloadFullSound
@onready var sound_shot01 : AudioStreamPlayer2D = $Sounds/Shot01
@onready var sound_shot_empty : AudioStreamPlayer2D = $Sounds/ShotEmpty
@onready var timer_reload : Timer = $Timers/ReloadTimer
@onready var timer_shot_delay : Timer = $Timers/ShotDelay
@onready var Hud : CanvasLayer = $"../../HUD"
@onready var Player : CharacterBody2D = $"../"

var Bullet : PackedScene = preload("res://scenes/bullet.tscn")

func _ready() -> void:
	timer_reload.timeout.connect(_on_reload_timer_timeout)
	timer_shot_delay.timeout.connect(_on_shot_delay_timeout)
	set_gun_type(GunType.SMG)

func _physics_process(_delta: float) -> void:
	camera_rotation()

func set_state(new_state: States) -> void:
	state = new_state
	emit_signal("gun_state", state)

	if state == States.SHOOTING:
		shot_anim()
	elif state in [States.RELOADINGFULL, States.RELOADINGPARTIAL]:
		reload_anim()

func set_gun_type(new_type: GunType) -> void:
	gun_type = new_type
	emit_signal("gun_type_signal", gun_type)

	if gun_type == GunType.PISTOL:
		mag_count = 6
		mag_size = 9
		Hud.ammo_bar.max_value = mag_size
		ammo = mag_size
		bullet_speed = 1000
		damage = 18.0
		shot_delay = 0.4
		full_reload_duration = 2.2
		partial_reload_duration = 1.1
	elif gun_type == GunType.SMG:
		mag_count = 4
		mag_size = 40
		Hud.ammo_bar.max_value = mag_size
		ammo = mag_size
		bullet_speed = 1200
		damage = 12.0
		shot_delay = 0.06
		full_reload_duration = 2.2
		partial_reload_duration = 1.1

# reloading
func reload() -> void:
	if state in [States.SHOOTING, States.RELOADINGFULL, States.RELOADINGPARTIAL] or mag_count <= 0:
		return

	# timer_shot_delay.stop() # to prevent player shooting while reloading

	var reload_type = States.RELOADINGFULL if ammo <= 0 else States.RELOADINGPARTIAL
	set_state(reload_type)

	if state == States.RELOADINGFULL:
		timer_reload.wait_time = full_reload_duration
		sound_reload_full.play()
	elif state == States.RELOADINGPARTIAL:
		timer_reload.wait_time = partial_reload_duration
		sound_reload_partial.play()

	timer_reload.start()
	reload_anim()
	Hud.show_reload_hint("reloading")

func _on_reload_timer_timeout() -> void:
	set_state(States.IDLE)
	ammo = mag_size
	mag_count -= 1
	Hud.ammo_bar.indeterminate = false

# shooting
func shoot() -> void:
	if state == States.IDLE:
		set_state(States.SHOOTING)
		timer_shot_delay.wait_time = shot_delay
		timer_shot_delay.start()

		var bullet = Bullet.instantiate() as Area2D
		bullet.position = muzzle.global_position
		bullet.velocity = get_muzzle_direction(bullet) * bullet.speed
		bullet.damage = damage
		get_tree().root.add_child(bullet)

		sound_shot01.play()
		ammo -= 1

		Player.area_shot.monitorable = true
		Player.area_shot.monitoring = true
		await get_tree().create_timer(0.1).timeout
		Player.area_shot.monitorable = false
		Player.area_shot.monitoring = false
	elif state == States.EMPTY and not sound_shot_empty.playing:
		sound_shot_empty.play()

func _on_shot_delay_timeout() -> void:
	if state == States.SHOOTING:
		set_state(States.IDLE)

func get_muzzle_direction(bullet: Area2D) -> Vector2:
	var cursor_position = get_global_mouse_position()
	var direction = (cursor_position - bullet.position).normalized()
	return direction

# Animations
func camera_rotation() -> void:
		var cursor_position = get_global_mouse_position()
		var direction = cursor_position - global_position
		rotation = lerp_angle(rotation, direction.angle(), 0.15) # smooth rotation
		sprite.flip_v = true if cursor_position.x < global_position.x else false

func shot_anim() -> void:
	var tween : Tween = create_tween()
	var cursor_position = get_global_mouse_position()
	var which_rotation = PI / 4 if cursor_position.x < global_position.x else -PI / 4

	tween.tween_property(sprite, "rotation", which_rotation, 0.025)
	tween.tween_property(sprite, "rotation", 0, 0.08).set_ease(Tween.EASE_OUT)

func reload_anim() -> void:
	var tween : Tween = create_tween()
	var cursor_position = get_global_mouse_position()
	var which_rotation = PI / 3 if cursor_position.x < global_position.x else -PI / 3
	var hold_time = 1.05

	tween.tween_property(sprite, "rotation", which_rotation, 0.075)
	if state == States.RELOADINGFULL:
		tween.tween_property(sprite, "rotation", 0, 0.08).set_ease(Tween.EASE_OUT).set_delay(hold_time)
		tween.tween_property(sprite, "position", sprite.position - Vector2(2, 0), 0.05).set_ease(Tween.EASE_IN).set_delay(0.5)
		tween.tween_property(sprite, "position", sprite.position, 0.05).set_ease(Tween.EASE_OUT)
	elif state == States.RELOADINGPARTIAL:
		tween.tween_property(sprite, "rotation", 0, 0.08).set_ease(Tween.EASE_OUT).set_delay(hold_time)
