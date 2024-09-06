extends Resource

class_name GunResource

# @export var gun_type : Global.GunType = Global.GunType.PISTOL
@export_enum("PISTOL", "REVOLVER", "SMG", "SHOTGUN", "AR")
var type : String = "PISTOL"
@export var damage : float = 0.0
@export var bullet_speed : float = 0.0
@export var spread : float = 0.0
@export var shot_delay : float = 0.0
@export var full_reload_duration : float = 0.0
@export var partial_reload_duration : float = 0.0
@export var mag_count : int = 0
@export var mag_size : int = 0
@export var sprite : Texture2D = null
@export var muzzle_position : Vector2 = Vector2.ZERO
@export var partial_reload_sound : AudioStream = null
@export var full_reload_sound : AudioStream = null
@export var shot_sound : AudioStream = null
@export var click_sound : AudioStream = null