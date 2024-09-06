extends Area2D

enum BoxType {ITEM, AMMO}

@export var box_type : BoxType
@export var gun_index : int
@export var mag_count : int

@onready var hitbox : CollisionShape2D = $CollisionShape2D
@onready var sprite : Sprite2D = $Sprite2D

var guns = [
	"pistol",
	"AR",
	"SMG"
]

func _ready() -> void:
	add_to_group("Boxes")

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if box_type == BoxType.AMMO:
			body.add_ammo(mag_count)
		elif box_type == BoxType.ITEM:
			body.change_gun(guns[gun_index])

		disable_box()
		show_floating_label()

func show_floating_label() -> void:
	var FloatingScore :PackedScene = load("res://scenes/floating_score.tscn")
	var floating_label = FloatingScore.instantiate() as Label
	var label_position_offset = Vector2(25, 35)
	floating_label.position = global_position - label_position_offset
	floating_label.z_index = 8

	if box_type == BoxType.AMMO:
		floating_label.text = "+" + str(mag_count) + " mags"
	elif box_type == BoxType.ITEM:
		floating_label.text = str(guns[gun_index])

	get_tree().root.add_child(floating_label)

	var tween : Tween = floating_label.create_tween()
	tween.tween_property(floating_label, "position", floating_label.position + Vector2(0, -30), 2).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(floating_label, "modulate", Color(1, 1, 1, 0), 2).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(sprite, "modulate", Color(1, 1, 1, 0), 1).set_ease(Tween.EASE_OUT)
	tween.finished.connect(queue_free)

func disable_box() -> void:
	hitbox.disabled = true
	monitorable = false
	monitoring = false
	collision_layer = 0
	collision_mask = 0