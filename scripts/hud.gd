extends CanvasLayer

@onready var health_bar : ProgressBar = $HealthBar
@onready var ammo_bar : ProgressBar = $AmmoBar
@onready var score_label : Label = $Kills/KillsCounter # a
@onready var player : CharacterBody2D = $"../Player"

func _ready() -> void:
	health_bar.max_value = player.max_health
	ammo_bar.max_value = player.max_ammo

	player.ammo_changed.connect(update_ammo)
	player.health_changed.connect(update_health)

func update_score(score: int) -> void:
	score_label.text = str(score)

func update_health(health: float) -> void:
	health_bar.value = health

func update_ammo(ammo: int) -> void:
	ammo_bar.value = ammo
	if ammo == 0:
		show_reload_hint("reload")
	else:
		show_reload_hint()

func show_reload_hint(label_text: String = ""):
	if label_text:
		$AmmoBar/ReloadHint.visible = true
		$AmmoBar/ReloadHint.text = label_text
	else:
		$AmmoBar/ReloadHint.visible = false
