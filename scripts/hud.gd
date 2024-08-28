extends CanvasLayer

@onready var health_bar : ProgressBar = $HealthBar
@onready var ammo_bar : ProgressBar = $AmmoBar
@onready var score_label : Label = $Kills/KillsCounter # a
@onready var player : CharacterBody2D = $"../Player"

func _ready() -> void:
  health_bar.max_value = player.max_health
  ammo_bar.max_value = player.max_ammo

func update_score(score: int) -> void:
  score_label.text = str(score)

func update_health(health: int) -> void:
  health_bar.value = health

func update_ammo(ammo: int) -> void:
  ammo_bar.value = ammo
