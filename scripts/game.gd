extends Node2D

@onready var player_instance : CharacterBody2D = $Player
@onready var hud : CanvasLayer = $HUD
@onready var zombie_spawner : Node2D = $ZombieSpawner

var tilemap_walls : TileMapLayer = null

var maps = [
	"res://scenes/maps/half_circles.tscn",
	"res://scenes/maps/bar.tscn",
]

func _ready() -> void:
	load_level()
	spawn_player()
	zombie_spawner.spawn_zombies(50)


func load_level() -> void:
	var random_index = randi() % maps.size()
	var map_path = maps[random_index]
	var map_scene : PackedScene = load(str(map_path))
	
	var map = map_scene.instantiate()
	add_child(map)
	tilemap_walls = map.get_node("walls")

func spawn_player() -> void:
	if player_instance:
		player_instance.position = find_valid_spawn_position()

func find_valid_spawn_position() -> Vector2:
	var valid_position = false
	var new_position : Vector2

	while not valid_position:
		new_position = Global.gen_random_position()
		if new_position.distance_to(tilemap_walls.local_to_map(new_position)) > 320.0:
			valid_position = true

	Global.player_position = new_position
	return new_position
