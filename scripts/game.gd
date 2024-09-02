extends Node2D

signal map_loaded

@onready var player_instance : CharacterBody2D = $Player
@onready var hud : CanvasLayer = $HUD
@onready var zombie_spawner : Node2D = $ZombieSpawner

var tilemap_walls : TileMapLayer = null

var maps = [
	"res://scenes/maps/half_circles.tscn",
	"res://scenes/maps/blocks.tscn",
	"res://scenes/maps/blocks02.tscn",
	"res://scenes/maps/rooms.tscn",
]

func _ready() -> void:
	Engine.max_fps = 120
	load_level()
	zombie_spawner.spawn_zombies(10)


func load_level() -> void:
	var random_index = randi() % maps.size()
	var map_path = maps[random_index]
	var map_scene : PackedScene = load(str(map_path))

	var map = map_scene.instantiate()
	add_child(map)
	Global.tilemap_walls = map.get_node("walls")
	Global.map_used_cells_to_global()

	spawn_player()


func spawn_player() -> void:
	if player_instance:
		var spawn_position = Global.spawnable_cells.pick_random()
		player_instance.position = spawn_position
		Global.player_position = spawn_position
		Global.spawnable_cells.erase(spawn_position)
