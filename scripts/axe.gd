extends Node3D

@export var item_id = 12
@export var item_name:String
@onready var ray_cast_3d: RayCast3D = $axe/RayCast3D
@onready var axe: Node3D = $axe
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
const GORE_WET_4 = preload("res://audio/sfx/Gore_Wet_4.wav")
var is_stop:bool = true
var can_hit:bool = true
func _ready() -> void:
	Event.connect("on_fire",hit)

func _physics_process(delta: float) -> void:
	if ray_cast_3d.is_colliding():
		var collider = ray_cast_3d.get_collider() 
			
		stop(true,collider)

var tween

func stop(colllide:bool = false,collider:Node = null):
	if is_stop:return
	if colllide:
		if collider.is_in_group("enemy"):
			collider.set_hp(1)
			Event.play_Gsfx(GORE_WET_4)
		else:
			if collider.get("item_id") == -3:
				collider.crash()
			audio_stream_player.play()
			spawn_part()
			await animate_reset()
			return

func animate_reset() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(axe,"rotation_degrees",Vector3(0,0,-90),0.6)
	is_stop = true
	await tween.finished
	can_hit = true
func hit():
	if !can_hit: return
	if tween:
		tween.kill()
	tween = create_tween()
	can_hit = false
	is_stop = false
	tween.tween_property(axe,"rotation_degrees",Vector3(-90,0,-90),0.1)
	await tween.finished
	animate_reset()

func spawn_part():
	var data = {
		"spawn_obj_id": 13,
		"obj_position": ray_cast_3d.global_position,
		"obj_rotation": ray_cast_3d.global_rotation,
		"obj_scale": Vector3(1, 1, 1),
		"amount": 1,
		"impulse": Vector3(0, 0, 0),
		"pl_id": Event.mpp_index
		}
	Event.emit_signal("spawn_obj",data)
