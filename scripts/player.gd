extends CharacterBody2D

@export var speed = 200
@export var max_health = 100
@export var health : int
@export var max_ammo = 12
@export var ammo : int

# @onready var hitbox : CollisionPolygon2D = $Hitbox
@onready var hud : CanvasLayer = $"../HUD"
@onready var damage_cooldown : Timer = $DamageCooldown
@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D

const radius = 12
var can_be_damaged = true

func _ready() -> void:
	health = max_health
	ammo = max_ammo
	hud.update_health(health)
	hud.update_ammo(ammo)
	damage_cooldown.timeout.connect(_on_damage_cooldown_timeout)

func _physics_process(_delta: float) -> void:
	get_input()
	move_and_slide()
	# camera_rotation()
	update_animation()

	# collision
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var body := collision.get_collider()
		print("Player collided with: ", body)
		if body.is_in_group("Zombies"):
			player_hit(body.attack)

func get_input() -> void:
	var input_dir = Input.get_vector("left", "right", "up", "down")
	velocity = input_dir * speed

# func camera_rotation() -> void:
# 		var cursor_position = get_global_mouse_position()
# 		var direction = cursor_position - global_position
# 		rotation = lerp_angle(rotation, direction.angle(), 0.15) # smooth rotation

func player_hit(damage: int) -> void:
	if can_be_damaged:
		print("Can be damaged? ", can_be_damaged)
		can_be_damaged = false
		health -= damage
		print("damage: ", health)
		damage_cooldown.start()
		hud.update_health(health)

func _on_damage_cooldown_timeout() -> void:
	can_be_damaged = true

func player_death() -> void:
	pass

func update_animation() -> void:
	if velocity.length() > 0:
		sprite.play("walk")
	else:
		sprite.play("idle")

	var cursor_position = get_global_mouse_position()
	if cursor_position.x > position.x:
		sprite.flip_h = false
	elif cursor_position.x < position.x:
		sprite.flip_h = true