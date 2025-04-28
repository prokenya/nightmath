extends Node

@export var rotateble_object: Node = self
@export var obj_rotation: Vector3
@export var rotation_time: float = 1
@onready var start_rotation: Vector3 = Vector3.ZERO

@export_group("SFX")
@export var open_sound:AudioStream
@export var open_play_on_start:bool = true
@export var close_sound:AudioStream
@export var close_play_on_start:bool = true
@export var db:float = 0.0

@onready var stream_player

var item_id = -4
var is_open = false

func _ready() -> void:
	start_rotation = rotateble_object.rotation
	obj_rotation = update_rotation(obj_rotation)
	if open_sound != null or close_sound != null:
		stream_player = AudioStreamPlayer.new()
		add_child(stream_player)
		stream_player.bus = "SFX"
		stream_player.volume_db = linear_to_db(db)
		

func update_rotation(rotat):
	return Vector3(
		deg_to_rad(rotat.x),
		deg_to_rad(rotat.y),
		deg_to_rad(rotat.z)
	)

var tween

func use():
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	
	if !is_open:
		tween.tween_property(rotateble_object, "rotation", obj_rotation, rotation_time)
	else:
		tween.tween_property(rotateble_object, "rotation", start_rotation, rotation_time)
	
	is_open = !is_open
	play_sound(tween, is_open)


func play_sound(tween,is_open) -> bool:
	if stream_player != null:
		stream_player.stream = close_sound if !is_open else open_sound
		var play_on_start = close_play_on_start if !is_open else open_play_on_start
		if play_on_start:
			stream_player.play()
		else:
			await tween.finished
			stream_player.play()
		return true
	else:
		return false
