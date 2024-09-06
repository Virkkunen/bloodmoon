extends CanvasLayer

@onready var health_bar : ProgressBar = $HealthBar
@onready var ammo_bar : ProgressBar = $AmmoBar
@onready var reload_hint : Label = $AmmoBar/ReloadHint
@onready var mag_count_label : Label = $MagCountLabel
@onready var score_label : Label = $Kills/KillsCounter
@onready var Player : CharacterBody2D = $"../Player"
@onready var Gun : Node2D = $"../Player/Gun"
@onready var Spawner : Node2D = $"../ZombieSpawner"
@onready var FloatingScore : PackedScene = preload("res://scenes/floating_score.tscn")
@onready var fps_label : Label = $FPSLabel

@export var animation_speed = 12
var target_ammo_value : float
var target_health_value : float

func _ready() -> void:
	# health_bar.set_deferred("max_value", Player.max_health)
	health_bar.max_value = Player.max_health
	ammo_bar.max_value = Gun.mag_size
	score_label.text = "0"

	Gun.ammo_changed.connect(update_ammo)
	Gun.mag_changed.connect(update_mags)
	Gun.gun_changed.connect(update_gun)
	Player.health_changed.connect(update_health)
	Player.player_dead.connect(_on_player_dead)
	Global.score_changed.connect(update_score)

	$DEBUG.visible = true if Global.debug else false

func _process(delta: float) -> void:
	if ammo_bar.value != target_ammo_value:
		ammo_bar.value = lerp(ammo_bar.value, target_ammo_value, animation_speed * delta)
	if health_bar.value != target_health_value:
		health_bar.value = lerp(health_bar.value, target_health_value, animation_speed * delta)

	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())

func update_score() -> void:
	score_label.text = str(Global.score)
	show_floating_score()

func update_health(health: float) -> void:
	target_health_value = health

func update_ammo(ammo: int, mags: int) -> void:
	target_ammo_value = float(ammo)
	if ammo == 0 and mags > 0:
		show_reload_hint("reload")
	elif ammo == 0 and mags <= 0:
		show_reload_hint("empty")
	else:
		show_reload_hint()

func update_mags(mags: int) -> void:
	mag_count_label.text = str(mags) + " mags"

func show_reload_hint(label_text: String = ""):
	if label_text:
		reload_hint.visible = true
		reload_hint.text = label_text
		if label_text == "reloading":
			ammo_bar.indeterminate = true
			mag_count_label.visible = false
	else:
		reload_hint.visible = false
		ammo_bar.indeterminate = false
		mag_count_label.visible = true

func show_floating_score() -> void:
	var floating_label = FloatingScore.instantiate() as Label
	var score_label_position = score_label.global_position
	var score_label_offset = Vector2(0, 15)
	floating_label.position = score_label_position - score_label_offset
	add_child(floating_label)

	var tween : Tween = floating_label.create_tween()
	tween.tween_property(floating_label, "position", floating_label.position + Vector2(0, -30), 0.5).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(floating_label, "modulate", Color(1, 1, 1, 0), 0.5).set_ease(Tween.EASE_OUT)
	tween.finished.connect(floating_label.queue_free)

func _on_player_dead() -> void:
	queue_free()

func update_gun(ammo: int, mag_count: int, mag_size: int, gun_type: int) -> void:
	print("received signal")
	Gun = get_parent().get_node("Player").get_node("Gun")
	Gun.ammo_changed.connect(update_ammo)
	Gun.mag_changed.connect(update_mags)
	Gun.gun_changed.connect(update_gun)
	# update_ammo(ammo, mag_count)
	# update_mags(mag_count)
	# ammo_bar.max_value = mag_size