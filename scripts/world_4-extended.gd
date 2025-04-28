extends "res://scripts/world.gd"
@onready var objects: Node3D = $objects
@onready var knifes_animation: AnimationPlayer = $knifes/knifes_Animation
@onready var camera_3d: Camera3D = $Camera3D
const GORE_WET_4 = preload("res://audio/sfx/Gore_Wet_4.wav")
@onready var rich_text_label: RichTextLabel = $Control/RichTextLabel



func _ready():
	show_players()
	get_tree().paused = false
	Event.connect("switch_scene",switch_scene)
	Event.register_object("world",self)
	Event.world = self
	var path = get_scene_file_path()
	if Event.userdata.fun_mode:
		if path == "res://scen/levels/world2.tscn":
			Event.can_use_random_event = true
		else:
			Event.can_use_random_event = false
	else:
		Event.can_use_random_event = false
	if Event.start_world_args.has("spawn_point"):
		spawn.position = Event.start_world_args["spawn_point"]
	world_objects.load_obj(path)
		
	user_prefs = UserPref.load_or_create()
	if Event.is_multiplayer == false:
		player = load("res://scen/character.tscn").instantiate()
		player.position = spawn.position
		player.kill_movment = true
		add_child(player)
		var data = {
		"spawn_obj_id": -1,
		"obj_position": enemy_point.global_position,
		"obj_rotation": Vector3(0,0,0),
		"obj_scale": Vector3(1, 1, 1),
		"amount": 1,
		"impulse": Vector3(0, 0, 0),
		"pl_id": Event.mpp_index,
		"custom_properties":{"area_3monitoring":false,"current_target":player,
		"current_state":0}
		}
		if spawn_enemy:
			Event.emit_signal("spawn_obj",data)
		if Event.userdata.fun_mode:
			await get_tree().create_timer(5).timeout
			knifes_animation.play("hit")
			await get_tree().create_timer(10).timeout
			camera_3d.current = true
		else:
			for child in objects.get_children():
				child.queue_free()
			knifes_animation.play("hit")
			await get_tree().create_timer(10).timeout
			camera_3d.current = true

func show_players():
	var player_names = Event.userdata.players_names
	for player_name in player_names:
		rich_text_label.append_text("[p][color=red]%s[/color][/p]" % player_name)
		await get_tree().create_timer(1).timeout

func _on_knifes_animation_animation_finished(anim_name: StringName) -> void:
	Event.play_Gsfx(GORE_WET_4)
	player.set_hp(999)	
