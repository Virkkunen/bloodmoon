extends Area2D

enum BoxType {ITEM, AMMO}

@export var box_type : BoxType
@export var gun_type : Global.GunType
@export var mag_count : int

var guns = [
	"res://scenes/guns/pistol.tscn",
	"res://scenes/guns/SMG.tscn",
	"res://scenes/guns/SMG.tscn",
	"res://scenes/guns/SMG.tscn",
	"res://scenes/guns/AR.tscn",
]

func _ready() -> void:
	add_to_group("Boxes")

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if box_type == BoxType.AMMO:
			body.add_ammo(mag_count)
		elif box_type == BoxType.ITEM:
			body.change_gun(guns[gun_type])
		queue_free()
