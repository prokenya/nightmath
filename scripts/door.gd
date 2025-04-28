#@tool
extends StaticBody3D
@export var item_id = -3
@onready var door:= $".."
@onready var door_2: MeshInstance3D = $"../../Door2"
@onready var cdoor_1: Node3D = $"../../cdoor1"
@onready var cdoor_2: Node3D = $"../../cdoor2"


@export var animation_player: AnimationPlayer
@export var navigation_link: NavigationLink3D
@export var code:String = ""
@export var usercode:String = "null"
@onready var rotor: Node3D = $"../.."
@onready var label_3d: Label3D = $"../Label3D"
@onready var label_3d_2: Label3D = $"../Label3D2"
@export var author:String = "door"



@export var door_number := "":
	set(value):
		if Engine.is_editor_hint():
			door_number = value
			label_3d.text = door_number
			label_3d_2.text = door_number
	get():
		return door_number



@onready var playlist: Array = [LoadResouce.load_resource("res://audio/sfx/open-door-sound-247415.mp3"),
				LoadResouce.load_resource("res://audio/sfx/close-door-sound-247450.mp3"),
				LoadResouce.load_resource("res://audio/sfx/door_handle_jiggle_checking.wav"),
				LoadResouce.load_resource("res://audio/sfx/DesignedCarCrash2.wav")]

var is_open = false
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $"../../../AudioStreamPlayer3D"
@export var hp:int = 5
func crash():
	hp -= 1
	if hp <= 5:
		door.visible = false
		door_2.visible = false
		cdoor_2.visible = true
	if hp <=0:
		cdoor_2.visible = false
		cdoor_1.visible = true
		set_collision_layer_value(1,false)
		audio_stream_player_3d.stream = playlist[3]
		audio_stream_player_3d.play()
		var data = {
		"spawn_obj_id": 13,
		"obj_position": $Area3D/CollisionShape3D.global_position,
		"obj_rotation": Vector3.ZERO,
		"obj_scale": Vector3(1, 1, 1),
		"amount": 5,
		"impulse": Vector3(0, 0, 0),
		"pl_id": Event.mpp_index
		}
		Event.emit_signal("spawn_obj",data)

func open_key(key):
	usercode = key

	if usercode == code:
		if Event.iteraction_menu.is_connected("submitted", open_key):
			Event.iteraction_menu.disconnect("submitted", open_key)
		Event.iteraction_menu.close_iteraction(false)

func open(skip_key:bool = false):
	if !skip_key:
		if code != "" and usercode != code:
			audio_stream_player_3d.stream = playlist[2]
			audio_stream_player_3d.play()
			Event.iteraction_menu.set_iteraction(1, "", author)
			if not Event.iteraction_menu.is_connected("submitted", open_key):
				Event.iteraction_menu.connect("submitted", open_key)
			return false
	var tween = create_tween()
	tween.stop()
	if is_open:
		audio_stream_player_3d.stream = playlist[1]
		tween.tween_property(rotor, "rotation_degrees", Vector3(0, 0, 0), 1)
		tween.play()

	else:
		audio_stream_player_3d.stream = playlist[0]
		tween.tween_property(rotor, "rotation_degrees", Vector3(0, 90, 0), 1)
		tween.play()
		
	audio_stream_player_3d.play()
	is_open = not is_open
	#await get_tree().create_timer(1).timeout




#func _ready() -> void:
	#navigation_link.enabled = false
#func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	#navigation_link.enabled = is_open


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	is_open = not is_open



#func _on_trigger_body_exited(body: Node3D) -> void:
	#if body.is_in_group("player"):
		#if Event.iteraction_menu.is_connected("submitted", open_key):
			#Event.iteraction_menu.disconnect("submitted", open_key)
		#Event.iteraction_menu.close_iteraction(false)
