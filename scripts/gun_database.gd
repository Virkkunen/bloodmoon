extends Node2D

var cache : Dictionary = {}

@export_dir var gun_folder

func _ready() -> void:
	pass
	# var folder = DirAccess.open(gun_folder)
	# print(folder.get_open_error())
	# folder.list_dir_begin()

	# var file_name = folder.get_next()

	# while file_name != "":
	# 	cache[file_name] = load(gun_folder + "/" + file_name)
	# 	file_name = folder.get_next()

func get_gun(id: String):
	return cache[id + ".tres"]
