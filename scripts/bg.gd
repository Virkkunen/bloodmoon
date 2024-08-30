extends TileMapLayer

var tile_size = 16

func _ready() -> void:
  pass
	# var columns = Global.game_size.x / tile_size
	# var rows = Global.game_size.y / tile_size

	# for x in range(columns):
	# 	for y in range(rows):
	# 		var tile_index = Vector2i(randi_range(-1, 1), randi_range(-1, 1))
	# 		var pos = Vector2i(x, y)
	# 		set_cell(pos, -1, tile_index)
