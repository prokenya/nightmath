extends "res://scripts/world.gd"
func _ready():
	get_tree().paused = false
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
		add_child(player)
	await get_tree().create_timer(0.2).timeout
	await find_players_in_group()
	if Event.mpp_index >= 0 and Event.mpp_index < players.size():
		players[Event.mpp_index].position = spawn.position
	items = Event.items
	Event.connect("switch_scene",switch_scene)
	PhysicsServer3D.area_set_param(get_world_3d().get_space(), PhysicsServer3D.AREA_PARAM_GRAVITY, 2.0)
	player.gravity = 2.0


func _process(delta: float) -> void:
	if player.position.y < -50:
		player.velocity = Vector3.ZERO

		player.position = Vector3(-19.602,3,5.5)

func enemy_rage():
	switch_scene(false,"res://scen/levels/world4.tscn",false)
	if enemy != null:
		enemy.enemy_rage(enemy_point)

func enemy_reset(correct:bool = false):
	if enemy != null:
		enemy.enemy_reset(-1,correct)
		trigger1.is_triggered = true

@onready var audio_stream_player_3d: AudioStreamPlayer = $AudioStreamPlayer3D

func _on_audio_stream_player_3d_finished() -> void:
	audio_stream_player_3d.play(randf_range(0,3))
	audio_stream_player_3d.pitch_scale = randf_range(0.6,1.5)
