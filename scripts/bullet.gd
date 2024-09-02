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
  print(body.name)
  if body.is_in_group("Walls") or body.name == "walls":
    queue_free()
  #   print("hit zombie ", body.name)
  #   body.get_hit(damage)
  # queue_free()

func _on_area_entered(area: Area2D) -> void:
  if area.name == "ZombieVision":
    return
  var area_body = area.get_parent()
  if area_body.is_in_group("Zombies"):
    if area.name == "Head":
      area_body.get_hit(damage * 1.2)
      if Global.debug:
        print("Hit ", area_body.name, " on ", area.name, ", damage: ", damage * 1.2)
    else:
      area_body.get_hit(damage)
      if Global.debug:
        print("Hit ", area_body.name, " on ", area.name, ", damage: ", damage)
  queue_free()

