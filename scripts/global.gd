extends Node2D

signal score_changed

@export var colour01 = Color.html("#eff9d6")
@export var colour02 = Color.html("#ba5044")
@export var colour03 = Color.html("#7a1c4b")
@export var colour04 = Color.html("#1b0326")
@export var zombies = []
@export var score = 0 :
  get:
    return score
  set(value):
    score = value
    emit_signal("score_changed")
@export var player_position : Vector2

@export var debug = true

var screen_size : Vector2
var screen_center : Vector2

@export var game_size = Vector2(2262, 1254)

func _ready() -> void:
  screen_size = get_viewport_rect().size
  screen_center = screen_size / 2

func gen_random_position() -> Vector2:
  return Vector2(randf_range(0, screen_size.x), randf_range(0, screen_size.y))