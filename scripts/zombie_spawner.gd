extends Node2D

var Zombie = preload("res://scenes/zombie.tscn")

@export var min_distance_from_player = 500
@export var min_distance_from_edges = 40

func spawn_zombies(num_zombies: int = 10) -> void:
	var valid_position = false
	var new_position : Vector2

	for i in num_zombies:
		var zombie = Zombie.instantiate()
		valid_position = false

		while not valid_position:
			new_position = Global.gen_random_position()
			# first check if near player
			if new_position.distance_to(Global.player_position) < min_distance_from_player:
				print("zombie close to player")
				continue # goto while
			# now check walls with a neat lambda function
			# I miss javascript
			var position_near_wall = Global.tilemap_used_cells.any(
				func(cell_position: Vector2) -> bool:
					return new_position.distance_to(cell_position) < Global.tilemap_walls.tile_set.tile_size.length()
			)

			if position_near_wall:
				print("zombie close to wall")
				continue

			valid_position = true

		zombie.position = new_position
		zombie.name = "Zombie " + str(i)
		Global.zombies.append(zombie)
		add_child(zombie)
