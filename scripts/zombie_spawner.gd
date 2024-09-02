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
			new_position = Global.spawnable_cells.pick_random()
			if new_position.distance_to(Global.player_position) < min_distance_from_player:
				# print("zombie close to player")
				continue # goto while

			valid_position = true

		zombie.position = new_position
		zombie.name = "Zombie " + str(i)
		Global.zombies.append(zombie)
		Global.spawnable_cells.erase(new_position)
		add_child(zombie)
