extends Area2D

@export var speed = 1200

var velocity = Vector2.ZERO

func _ready() -> void:
  add_to_group("Bullets")
  rotation = velocity.angle()

func _physics_process(delta: float) -> void:
  position += velocity * delta