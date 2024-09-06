extends Node2D

var Box = preload("res://scenes/box.tscn")

@export var min_distance_from_player = 250
@export var min_mag_count = 2
@export var max_mag_count = 5

func spawn_boxes(num_boxes : int = 15) -> void:
	var valid_position = false
	var new_position : Vector2

	for i in num_boxes:
		var box = Box.instantiate()
		valid_position = false

		while not valid_position:
			new_position = Global.spawnable_cells.pick_random()
			if new_position.distance_to(Global.player_position) < min_distance_from_player:
				# print("zombie close to player")
				continue # goto while

			valid_position = true

		box.position = new_position
		# box.box_type = randi() % 2
		box.box_type = 0
		box.mag_count = randi_range(min_mag_count, max_mag_count)
		box.gun_type = randi_range(0, Global.GunType.size() -1)
		box.name = "Box " + str(i)
		Global.spawnable_cells.erase(new_position)
		add_child(box)
