extends CharacterBody2D

signal zombie_killed

@export var speed = 40.0
@export var max_health = 150.0
@export var health : float :
	get:
		return health
	set(value):
		health = value
		if health <= 0:
			kill_zombie()

@export var max_damage = 25.0
@export var damage : float
@export var vision_radius : float
# @export var wander_time : float

@onready var navigation_agent : NavigationAgent2D = $NavigationAgent2D
@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var head : Area2D = $Head
@onready var zombie_body : Area2D = $Body
@onready var timer_navigation : Timer = $NavTimer
@onready var timer_wander : Timer = $WanderTimer

var direction = Vector2.ZERO
var destination : Vector2
var player_in_vision = false
var player : Node2D = null

func _ready() -> void:
	add_to_group("Zombies")
	health = randf_range(max_health - 0.2 * max_health, max_health)
	damage = randf_range(max_damage - 0.2 * max_damage, max_damage)

	timer_navigation.timeout.connect(_on_timer_navigation_timeout)
	timer_wander.timeout.connect(_on_timer_wander_timeout)
	

func _physics_process(_delta: float) -> void:
	direction = to_local(navigation_agent.get_next_path_position()).normalized()
	velocity = direction * speed
	move_and_slide()

	update_animation()

func update_animation() -> void:
	if velocity.length() > 0:
		sprite.play("walk")
	else:
		sprite.play("idle")

	# update_flip()
	if velocity.x < 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false

func sprite_colour_on_damage() -> void:
	var tween : Tween = create_tween()
	sprite.modulate = Global.colour03
	tween.tween_property(sprite, "modulate", Color(1, 1, 1), 0.3).set_ease(Tween.EASE_IN)

func get_hit(incoming_damage: float) -> void:
	sprite_colour_on_damage()
	health -= incoming_damage

func kill_zombie() -> void:
	# get score
	emit_signal("zombie_killed", self)
	if Global.zombies.has(self):
		Global.zombies.erase(self)
	Global.score += 1
	# stop physics
	set_physics_process(false)
	collision_layer = 0
	collision_mask = 0
	head.collision_layer = 0
	zombie_body.collision_layer = 0
	sprite.play("idle")
	# animation
	var tween : Tween = create_tween()
	tween.tween_property(sprite, "modulate", Global.colour03, 0.2).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(sprite, "rotation_degrees", 90, 0.1).set_ease(Tween.EASE_IN)
	tween.tween_property(sprite, "modulate", Color(0, 0, 0, 0), 0.3).set_delay(2)
	# remove zombie
	tween.finished.connect(self.queue_free)

func _on_zombie_vision_body_entered(body: Node2D) -> void:
	print(body.name)
	if body.name == "Player":
		speed = 50
		navigation_agent.target_position = body.global_position
		player_in_vision = true
		
		timer_navigation.wait_time = 0.5
		timer_navigation.one_shot = false
		timer_navigation.start()
		timer_wander.stop()

func _on_zombie_vision_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_vision = false
		timer_navigation.one_shot = true

func _on_timer_navigation_timeout() -> void:
	if player_in_vision:
		navigation_agent.target_position = Global.player_position
	else:
		timer_wander.start()

func _on_zombie_vision_area_entered(area: Area2D) -> void:
	if area.name == "Footsteps":
		print(area.name)
		navigation_agent.target_position = area.global_position
		player_in_vision = true
		timer_navigation.one_shot = false
		timer_navigation.wait_time = 0.8
		timer_navigation.start()

func _on_zombie_vision_area_exited(area: Area2D) -> void:
	# print("here")
	# player_in_vision = false
	# timer_navigation.one_shot = true
	pass

func _on_timer_wander_timeout() -> void:
	if not player_in_vision:
		speed = 10
		timer_wander.wait_time = randf_range(0.5, 4)
		timer_wander.start()

		navigation_agent.target_position = Global.gen_random_position()