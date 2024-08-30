extends Node2D

var Zombie = preload("res://scenes/zombie.tscn")

@export var min_distance_from_center = 500
@export var min_distance_from_edges = 40

# func _ready() -> void:
# 	spawn_zombies(randi_range(50, 100))

func spawn_zombies(num_zombies: int = 10) -> void:
	var valid_position = false

	for i in num_zombies:
		valid_position = false
		var zombie = Zombie.instantiate()

		while not valid_position:
			zombie.position = Global.gen_random_position()
			if is_valid_position(zombie.position):
				valid_position = true

		zombie.name = "Zombie " + str(i)
		Global.zombies.append(zombie)
		add_child(zombie)

func is_valid_position(pos: Vector2) -> bool:
	# distance to center
	var distance_from_center = pos.distance_to(Global.game_size / 2)
	if distance_from_center <= min_distance_from_center:
		return false

	# distance to edges
	var distance_from_left = pos.x
	var distance_from_right = Global.game_size.x - pos.x
	var distance_from_top = pos.y
	var distance_from_bottom = Global.game_size.y - pos.y

	if (distance_from_left < min_distance_from_edges or
			distance_from_right < min_distance_from_edges or
			distance_from_top < min_distance_from_edges or
			distance_from_bottom < min_distance_from_edges):
		return false

	return true
