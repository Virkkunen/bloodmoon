extends CanvasLayer

@onready var health_bar : ProgressBar = $HealthBar
@onready var ammo_bar : ProgressBar = $AmmoBar
@onready var reload_hint : Label = $AmmoBar/ReloadHint
@onready var score_label : Label = $Kills/KillsCounter
@onready var Player : CharacterBody2D = $"../Player"
@onready var Spawner : Node2D = $"../ZombieSpawner"
@onready var FloatingScore : PackedScene = preload("res://scenes/floating_score.tscn")
@onready var fps_label : Label = $FPSLabel

@export var animation_speed = 12
var target_ammo_value : float
var target_health_value : float

func _ready() -> void:
	health_bar.max_value = Player.max_health
	ammo_bar.max_value = Player.max_ammo
	score_label.text = "0"

	Player.ammo_changed.connect(update_ammo)
	Player.health_changed.connect(update_health)
	Player.player_dead.connect(_on_player_dead)
	Global.score_changed.connect(update_score)

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

func update_ammo(ammo: int) -> void:
	$DEBUG/ammo.text = "Ammo: " + str(ammo)
	target_ammo_value = float(ammo)
	if ammo == 0:
		show_reload_hint("reload")
	else:
		show_reload_hint()

func show_reload_hint(label_text: String = ""):
	if label_text:
		reload_hint.visible = true
		reload_hint.text = label_text
		if label_text == "reloading":
			ammo_bar.indeterminate = true
	else:
		reload_hint.visible = false
		ammo_bar.indeterminate = false

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