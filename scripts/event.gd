extends Node

var Gsfx = AudioStreamPlayer.new()
var platform
#world_data
@onready var world_scenes:Dictionary

var world:Node
var start_world_args: Dictionary
var items: Dictionary
var userdata:UserPref = UserPref.load_or_create()
var data:Data = Data.load_or_create()
var can_use_random_event = false
var object_registry = {"Event":self}
var current_events:Array[String] = []
var completion_events:Array[String] = []
@export var random_sounds:Array[AudioStream] = [preload("res://audio/sfx/Combat/DesignedGunshot_Pistol1.wav"),
preload("res://audio/sfx/bottle-cap-fall-86300.mp3"),
preload("res://audio/sfx/DesignedAxe4.wav"),
preload("res://audio/sfx/DesignedCarCrash2.wav"),
preload("res://audio/sfx/exp_1.ogg"),
preload("res://audio/sfx/fall-and-impact-38630.mp3"),
preload("res://audio/sfx/Monster_Roar_2.wav"),
preload("res://audio/sfx/select.wav"),
preload("res://audio/sfx/wood-crash-103157.mp3")]
#up_signals
signal charapter_update()
signal update_wold_setings()
signal spawn_obj(data: Dictionary)
signal set_animation(sate:int,oneshot_state:int,toggled:bool,kill_vision:bool)
#iter_call
signal switch_scene(path: int,save_obj:bool)
signal menu()
#console
signal printd(data,color:Color)
signal run_comand(comand: String)
#multiplayer
var is_multiplayer:bool = false
var mppnode
var mpcnode
var mpp_index:int
signal _on_player_connected(mpplayer)
#player
signal start_dialogue(idx:String,kui:bool)
signal _active_item(item_id,custom_properties)
var hp_char: int = 3
var is_inventory_active: bool
var avable_items_id:Array
var inventory_item_list:Array = [0,0,0,0,0,0]
var player_name:String
##control_player
signal drop_item(item_id,amount,custom_properties)
signal pick_up(player_id:int)
signal add_item(item_id:int,player_id:int,custom_properties:Dictionary)
signal remove_item(item, drop:bool, slot_id:int, item_amount:int, id:int)
signal jump()
signal on_fire(player_id:int)
var in_gui:bool
var iteraction_menu:Node
###sw_control
var control_id_counter:int = -1
var control_info = {
	"control_id": -1,
	"controller_id":-1,
	"controlled_object_type":"drone",
	"multiplayer_index":-1
	}
signal update_control(data:Dictionary)
func set_control(data):
	Event.emit_signal("update_control",data)
	control_info = data
#drone
var drone_speed: String = "0"
signal cam_1_3p(cam: bool,id:int)
signal reset_drone_pos()
func printc(text:String,color = Color.YELLOW):
	Event.emit_signal("printd",text,color)

func Eswitch_scene(path:String,save_obj:bool = true):
	Event.emit_signal("switch_scene",false,path,save_obj)


var events = {
	"event_ZERO": {
	"description": "zero_event",
	"actions": [{"target": "null", "method": "null", "args": [null]}],
	"rarity": 1,
	"duration": -1,
	"oneshot": false
	},
	"event_1": {
	"description": "m in_dialogue",
	"actions": [{"target": "dialogs", "method": "event_1", "args": ["event_1",true]}],
	"rarity": -3,
	"duration": -1,
	"oneshot":true
	},
	"event_2": {
	"description": "сбьеден гриб",
	"actions": [{"target": "env", "method": "event_2", "args": [0.15]}],
	"rarity": -3,
	"duration": 20
	},
	"event_3": {
	"description": "world2",
	"actions": [{"target": "world", "method": "switch_scene", "args": ["res://scen/levels/world1.tscn",true]}],
	"rarity": -1,
	"duration": -1,
	"oneshot": false
	},
	"event_4": {
	"description": "in_dialogue state",
	"actions": [{"target": "dialogs", "method": "event_4", "args": [0]}],
	"rarity": -3,
	"duration": -2
	},
	"event_5": {
	"description": "world3",
	"actions": [{"target": "world", "method": "switch_scene", "args": ["res://scen/levels/world3.tscn",true]}],
	"rarity": -1,
	"duration": -1,
	"oneshot": true
	},
	"random_sound": {
	"description": "random_sound",
	"actions": [{"target": "Event", "method": "play_random_sound", "args": [0]}],
	"rarity": 10,
	"duration": -1,
	"oneshot": false
	},
}

func _ready():
	Gsfx.bus = "SFX"
	add_child(Gsfx)
	platform = OS.get_name()
	#platform = "Android"
	if platform == "Android":
		print(platform)
	elif platform == "iOS":
		print("iOS")
	else:
		platform = "PC"
		print("PC")
	can_use_random_event = true
	if Event.userdata.locale == "null":
		if OS.get_locale_language() in ["ru","en","uk"]:
			Event.userdata.locale = OS.get_locale_language()
		else:
			Event.userdata.locale = "en"
		Event.userdata.save()
	var locale = Event.userdata.locale
	TranslationServer.set_locale(locale)

func play_Gsfx(soud:AudioStream):
	Gsfx.stream = soud
	Gsfx.play()

func load_scene(path: String) -> PackedScene:
	if not world_scenes.has(path):
		world_scenes[path] = load(path)
	return world_scenes[path]

func play_random_sound(stop,id:int = 0):
	if stop: return
	play_Gsfx(random_sounds.pick_random())

func OSalert(text,author:String = "//"):
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Input.vibrate_handheld(250)
	OS.alert(text,author)

func _physics_process(delta: float) -> void:
	if 9 in inventory_item_list and "event_1" not in completion_events:
		set_event("event_1")
	if control_info["control_id"] != -1 and can_use_random_event and randf()*10 < 0.001: # Вероятность
		generate_random_event()


func register_object(key: String, object: Node) -> void:
	object_registry[key] = object

func execute_event_action(key: String, method: String, args: Array,stop:bool = false) -> void:
	var obj = object_registry.get(key, null)
	if obj and obj.has_method(method):
		obj.callv(method, [stop] + args)
	else:
		print("Ошибка: Объект ", key, " не найден или не имеет метод ", method)


# Устанавливает событие
func set_event(event_id: String) -> void:
	if events.has(event_id):
		var event = events[event_id]
		_on_event_changed(event_id, event["description"], event["duration"])
	else:
		print("Событие с ID ", event_id, " не найдено.") 

# Генерирует случайное событие и вызывает set_event
func generate_random_event() -> void:
	var total_weight = 0
	for event_id in events.keys():
		var rarity = events[event_id]["rarity"]
		if rarity > 0:
			total_weight += rarity

	var random_value = randi() % total_weight
	var current_weight = 0

	for event_id in events.keys():
		var rarity = events[event_id]["rarity"]
		if rarity > 0:
			current_weight += rarity
			if random_value < current_weight:
				set_event(event_id)
				return

# Обработчик сигнала при смене события
func _on_event_changed(event_id: String, description: String, duration: int) -> void:
	#print("ID: ", event_id)
	var actions = events[event_id]["actions"]
	for action in actions:
		execute_event_action(action["target"], action["method"], action.get("args", []))
	set_duration(duration,event_id)

var timers: Dictionary = {}


func set_duration(time: float, event_id: String) -> void:
	if time == -1:
		close_event(event_id)
		return
	if time == -2:
		current_events.append(event_id)
		return
	if event_id in timers.keys():
		var timer = timers[event_id]
		var remaining_time = timer.time_left
		timer.stop()
		timer.wait_time = remaining_time + time
		timer.start()
		
	else:
		# Создаём новый таймер
		var timer = Timer.new()
		timer.wait_time = time
		timer.one_shot = true
		timer.name = event_id
		self.add_child(timer)
		timer.connect("timeout", close_event.bind(event_id))
		timer.start()
		timers[event_id] = timer
		current_events.append(event_id)

func close_event(event_id: String,call:bool = true) -> void:
	var timer_wait_time = 0
	if event_id in timers.keys():
		var timer = timers[event_id]
		timer_wait_time = round(timer.wait_time)
		timers.erase(event_id)
		timer.queue_free()
		
	current_events.erase(event_id)
	var actions = events[event_id]["actions"]
	if call:
		for action in actions:
			execute_event_action(action["target"], action["method"], action.get("args", []),true)
	if event_id not in completion_events:
		completion_events.append(event_id)
	if events[event_id].get("oneshot",false):
		events.erase(event_id)
		printc("rm " + str(event_id))
	print("Событие ", event_id, " завершено с длительностью ",timer_wait_time)

	

func get_username() -> String:
	var output = []
	
	if OS.get_name() == "Windows":
		OS.execute("cmd", ["/c", "echo %USERNAME%"], output)
	else:
		OS.execute("sh", ["-c", "echo $USER"], output)
	
	if output.size() > 0:
		return output[0].strip_edges()
	
	return ""
