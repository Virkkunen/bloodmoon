extends CharacterBody2D

signal zombie_killed

enum States {IDLE, WANDERING, CHARGING, SEARCHING, DEATH}

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

@export var state : States = States.IDLE : set = set_state

@onready var navigation_agent : NavigationAgent2D = $NavigationAgent2D
@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var head : Area2D = $Head
@onready var zombie_body : Area2D = $Body
@onready var timer_navigation : Timer = $NavTimer
@onready var timer_wander : Timer = $WanderTimer

var direction = Vector2.ZERO
var current_position : Vector2
var next_position : Vector2
var player_in_vision = false
var player : Node2D = null

func _ready() -> void:
	add_to_group("Zombies")
	health = randf_range(max_health - 0.2 * max_health, max_health)
	damage = randf_range(max_damage - 0.2 * max_damage, max_damage)

	timer_navigation.timeout.connect(_on_timer_navigation_timeout)
	timer_wander.timeout.connect(_on_timer_wander_timeout)
	

func _physics_process(_delta: float) -> void:
	# direction = to_local(navigation_agent.get_next_path_position()).normalized()
	# velocity = direction * speed
	if navigation_agent.is_navigation_finished():
		set_state(States.IDLE)
		return

	current_position = global_position
	next_position = navigation_agent.get_next_path_position()
	var new_velocity = current_position.direction_to(next_position) * speed

	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(new_velocity)

	move_and_slide()

	# sprite.play("walk") if velocity.length() > 0 else sprite.play("idle")
	sprite.flip_h = true if velocity.x < 0 else false

func set_state(new_state: States) -> void:
	# var previous_state = state
	state = new_state

	if state in [States.IDLE, States.DEATH]:
		sprite.play("idle")
	elif state in [States.WANDERING, States.CHARGING, States.SEARCHING]:
		sprite.play("walk")

func sprite_colour_on_damage() -> void:
	var tween : Tween = create_tween()
	sprite.modulate = Global.colour03
	tween.tween_property(sprite, "modulate", Color(1, 1, 1), 0.3).set_ease(Tween.EASE_IN)

func get_hit(incoming_damage: float) -> void:
	sprite_colour_on_damage()
	health -= incoming_damage

func kill_zombie() -> void:
	set_state(States.DEATH)
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
	head.collision_mask = 0
	zombie_body.collision_layer = 0
	zombie_body.collision_mask = 0
	sprite.play("idle")
	# animation
	var tween : Tween = create_tween()
	tween.tween_property(sprite, "modulate", Global.colour03, 0.2).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(sprite, "rotation_degrees", 90, 0.1).set_ease(Tween.EASE_IN)
	tween.tween_property(sprite, "modulate", Color(0, 0, 0, 0), 0.3).set_delay(2)
	# remove zombie
	tween.finished.connect(self.queue_free)

func _on_zombie_vision_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		set_state(States.CHARGING)
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
		set_state(States.WANDERING)
		timer_wander.start()

func _on_zombie_vision_area_entered(area: Area2D) -> void:
	if area.name == "ShotArea" and not player_in_vision:
		set_state(States.SEARCHING)
		navigation_agent.target_position = Global.player_position
		speed = 40
		timer_wander.stop()
		timer_navigation.one_shot = true
		timer_navigation.wait_time = 2
		timer_navigation.start()
		

func _on_zombie_vision_area_exited(_area: Area2D) -> void:
	pass	
	# print("here")
	# player_in_vision = false
	# timer_navigation.one_shot = true

func _on_timer_wander_timeout() -> void:
	if not player_in_vision:
		set_state(States.WANDERING)
		speed = 10
		timer_wander.wait_time = randf_range(1, 4)
		timer_wander.start()

		navigation_agent.target_position = Global.gen_random_position()

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity