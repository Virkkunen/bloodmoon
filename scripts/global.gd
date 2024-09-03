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
@export var level_name : String

@export var tilemap_ground : TileMapLayer = null
@export var tilemap_walls : TileMapLayer = null
@export var spawnable_cells : Array = []

@export var debug = false

var screen_size : Vector2
var screen_center : Vector2

@export var game_size = Vector2(2262, 1254)

func _ready() -> void:
	screen_size = get_viewport_rect().size
	screen_center = screen_size / 2

func gen_random_position() -> Vector2:
	return Vector2(randi_range(0, game_size.x), randi_range(0, game_size.y))

func map_used_cells_to_global() -> void:
	# this one will get all grass and floor tiles
	spawnable_cells.clear()
	var grass_cells = tilemap_ground.get_used_cells_by_id(1)
	# var wall_cells = tilemap_ground.get_used_cells_by_id(0)
	# var floor_cells = tilemap.get_used_cells_by_id(-1, Vector2i(9, 0), -1)
	# var used_cells = grass_cells
	# for wall in wall_cells:
		# grass_cells.erase(wall)

	for cell in grass_cells:
		var tile_local_position = tilemap_ground.map_to_local(cell)
		var tile_global_position = tilemap_ground.to_global(tile_local_position)
		spawnable_cells.append(tile_global_position)
