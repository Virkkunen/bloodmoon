extends Node2D

# @export var maze_size : Vector2 = Vector2(20, 15)
@export var cell_size : int = 64

@onready var Wall : PackedScene = preload("res://scenes/wall.tscn")

func _ready() -> void:
	# generate_maze()
	pass

func generate_maze() -> void:
	# var maze_size = Vector2((Global.game_size.x / cell_size), (Global.game_size.y / cell_size))
	var maze_width = Global.game_size.x / cell_size
	var maze_height = Global.game_size.y / cell_size

	var maze = init_maze(int(maze_width), int(maze_height))
	print(maze)
	for x in range(maze_width):
		for y in range(maze_height):
			if maze[x][y] == 1:
				var wall = Wall.instantiate()
				wall.position = Vector2(x * cell_size, y * cell_size)
				add_child(wall)
	
func init_maze(width: int, height: int) -> Array:
	return []