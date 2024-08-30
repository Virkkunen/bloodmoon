extends Node2D

@onready var player_instance : CharacterBody2D = $Player
@onready var hud : CanvasLayer = $HUD

func _ready() -> void:
	spawn_player()

# func spawn_player() -> void:
# 	if is_instance_valid(player_instance):
# 		player_instance.queue_free()
# 	player_instance = player_scene.instantiate()
# 	player_instance.position = Global.game_size / 2
# 	add_child(player_instance)

func spawn_player() -> void:
	if player_instance:
		player_instance.position = Global.game_size / 2
