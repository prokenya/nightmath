extends Node3D
@export var players: Array
@onready var spawn: Node3D = $spawn
@export var spawn_enemy:bool = false
@onready var enemy_point: Node3D = $"enemy point"
@onready var spawn_parent: Node3D = $"."
@onready var world_objects: Node3D = $objects
const plr = preload("res://scen/character.tscn")
var player
@onready var enemy:Node

@export var items:Dictionary
var user_prefs: UserPref

func _ready():
	player = plr.instantiate()
	player.position = spawn.position
	add_child(player)
	get_tree().paused = false
	Event.register_object("world",self)
	Event.world = self
	var path = get_scene_file_path()
	if Event.start_world_args.has("spawn_point"):
		spawn.position = Event.start_world_args["spawn_point"]
	world_objects.load_obj(path)
	user_prefs = UserPref.load_or_create()
	await get_tree().create_timer(0.2).timeout
	await find_players_in_group()
	#if Event.mpp_index >= 0 and Event.mpp_index < players.size():
		#players[Event.mpp_index].position = spawn.position
	items = Event.items
	var data = {
		"spawn_obj_id": -1,
		"obj_position": Vector3(3,3.3,10),
		"obj_rotation": Vector3.UP,
		"obj_scale": Vector3(1, 1, 1),
		"amount": 1,
		"impulse": Vector3(0, 0, 0),
		"pl_id": Event.mpp_index,
		"custom_properties":{
			"hp":1000
		}
		}
	if Event.userdata.level_objects.get(scene_file_path) == null:
		if spawn_enemy:
			Event.emit_signal("spawn_obj",data)
	Event.connect("switch_scene",switch_scene)
			
	
const TRANSITION_SFX = preload("res://audio/sfx/transition sfx.wav")
func switch_scene(stop,path,save_obj,speed:float = 1.0,sound:bool = true):
	if enemy:
		enemy.queue_free()
	if stop:
		return
	if save_obj:
		await world_objects.save_obj(get_scene_file_path())
	#Event.start_world_args = {"spawn_point":players[0].position}
	Event.in_gui = false
	if sound:
		Event.play_Gsfx(TRANSITION_SFX)
	get_tree().paused = true
	SceneManager.change_scene(Event.load_scene(path),
		 {"invert_on_leave": false,"wait_time": 1,"color":Color.DARK_RED,"speed":speed})

@onready var trigger1: trigger = $triggers/trigger

func die(dm:int):
	enemy.die(player,dm,enemy_point)
	if dm == 0:
		player.kill_movment = true
		await get_tree().create_timer(2.2).timeout
		player.position = spawn.position
		player.rotation = Vector3.ZERO
		enemy.position = enemy_point.position
		await get_tree().create_timer(2.0).timeout
		trigger1.is_triggered = false
		player.kill_movment = false
	else:
		trigger1.is_triggered = true

func enemy_rage():
	if enemy != null:
		enemy.enemy_rage(enemy_point)
		trigger1.is_triggered = true

func enemy_reset(correct:bool = false):
	if enemy != null:
		enemy.enemy_reset(enemy_point,correct)
		trigger1.is_triggered = true
	

func find_players_in_group() -> void:
	players = []
	var scene_tree = get_tree()

	# Проверка на то, что группа существует и не пуста
	if scene_tree.has_group("player"):
		for node in scene_tree.get_nodes_in_group("player"):
			players.append(node)
		#print("Игроки найдены: ", players)
	else:
		print("Группа 'player' не найдена или пуста.")

func _on_objects_child_entered_tree(node: Node) -> void:
	if node.is_in_group("enemy"):
		enemy = node


func _on_trigger_exited(body: Variant) -> void:
	if enemy != null:
		Event.world.enemy_rage()
