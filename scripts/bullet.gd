extends Area2D

@export var speed = 1200.0
@export var damage = 25.0

var velocity = Vector2.ZERO

func _ready() -> void:
  add_to_group("Bullets")
  rotation = velocity.angle()

func _physics_process(delta: float) -> void:
  position += velocity * delta

func _on_body_entered(body: Node2D) -> void:
  if body.is_in_group("Zombies"):
    print("hit zombie ", body)
    body.get_hit(damage)
  queue_free()