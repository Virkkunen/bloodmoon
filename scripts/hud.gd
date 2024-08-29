extends CanvasLayer

@onready var health_bar : ProgressBar = $HealthBar
@onready var ammo_bar : ProgressBar = $AmmoBar
@onready var reload_hint : Label = $AmmoBar/ReloadHint
@onready var score_label : Label = $Kills/KillsCounter
@onready var Player : CharacterBody2D = $"../Player"
@onready var Spawner : Node2D = $"../ZombieSpawner"

@export var animation_speed = 12
var target_ammo_value : float
var target_health_value : float

func _ready() -> void:
	health_bar.max_value = Player.max_health
	ammo_bar.max_value = Player.max_ammo

	Player.ammo_changed.connect(update_ammo)
	Player.health_changed.connect(update_health)
	Global.score_changed.connect(update_score)

	update_score()

func _process(delta: float) -> void:
	if ammo_bar.value != target_ammo_value:
		ammo_bar.value = lerp(ammo_bar.value, target_ammo_value, animation_speed * delta)
	if health_bar.value != target_health_value:
		health_bar.value = lerp(health_bar.value, target_health_value, animation_speed * delta)

func update_score() -> void:
	score_label.text = str(Global.score)

func update_health(health: float) -> void:
	target_health_value = health

func update_ammo(ammo: int) -> void:
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