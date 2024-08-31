extends Node2D

signal map_loaded

@onready var player_instance : CharacterBody2D = $Player
@onready var hud : CanvasLayer = $HUD
@onready var zombie_spawner : Node2D = $ZombieSpawner

var tilemap_walls : TileMapLayer = null

var maps = [
	"res://scenes/maps/half_circles.tscn",
	"res://scenes/maps/bar.tscn",
	"res://scenes/maps/city.tscn",
]

func _ready() -> void:
	load_level()
	zombie_spawner.spawn_zombies(100)


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
		var valid_position = false
		var new_position : Vector2

		while not valid_position:
			new_position = Global.gen_random_position()

			var position_near_wall = Global.tilemap_used_cells.any(
				func(cell_position: Vector2) -> bool:
					return new_position.distance_to(cell_position) < Global.tilemap_walls.tile_set.tile_size.length() / 4
			)

			if position_near_wall:
				print("player close to wall")
				continue
			
			valid_position = true

		player_instance.position = new_position
		Global.player_position = new_position