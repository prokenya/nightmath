extends CanvasLayer

@onready var locale_button: OptionButton = %locale
var locales = ["en","ru","uk"]
var username
@onready var text_mesh: CSGMesh3D = $bg/SubViewportContainer/SubViewport/bg/CSGMesh3D
@onready var fun_mode: CheckButton = $"Control/menu/HBoxContainer/fun mode"
@onready var warning_texts:Dictionary = Event.data.in_code_localisation
@onready var line_edit: LineEdit = %LineEdit



func _ready():
	get_tree().paused = false
	
	# Setting saving userdata
	var locale = Event.userdata.locale
	locale_button.selected = locales.find(locale)
	fun_mode.button_pressed = Event.userdata.fun_mode


	# Getting username
	if Event.userdata.players_names.is_empty():
		username = Event.get_username()
	else:
		username = Event.userdata.players_names.back()
	
	text_mesh.mesh.text = username
	line_edit.text = username
	# clear no_save_exit data
	Event.completion_events = []
	Event.start_world_args = {}
	if Event.userdata.first_run:
		Event.OSalert(warning_texts[locale][2] + Event.get_username())
	Event.userdata.inventory_items.clear()
	Event.userdata.level_objects.clear()
	Event.userdata.first_run = false
	Event.userdata.save()
	
#region window
	# Window settings (PC)
	if Event.platform == "PC": 
		get_viewport().gui_embed_subwindows = false

	# Creating and configuring window
	#var V = Window.new()
	#V.initial_position = 2
	#V.transparent_bg = true
	#add_child(V)
	#$AspectRatioContainer.visible = true
	#$AspectRatioContainer.reparent(V)
#endregion

	# Notification and GUI initialization
	SceneManager.fade_in({"pattern_leave": "circle", "speed": 1})
	Event.in_gui = false

	# Displaying inventory information
	Event.printc("items:" + str(len(InventoryManager.items.keys())) + "\nid:" +
		str(InventoryManager.items.keys()), Color.GREEN)

	# Initializing controls
	Event.control_info = {
		"control_id": -1,
		"controller_id": -1,
		"controlled_object_type": "drone",
		"multiplayer_index": -1
	}

	
@onready var active_layer = [$Control/menu,$Control/select_level,$Control/settings,%credits]
@onready var menu_button: CanvasLayer = $Control/menub
var active_layer_id: = 0

var switchid:int

func pressed(id):
	if id == 0:
		menu_button.hide()
		await SceneManager.fade_out({"pattern": "horizontal","speed":5})
	else: 
		await SceneManager.fade_out({"pattern": "horizontal","speed":5})
		menu_button.show()
			
	active_layer[active_layer_id].visible = false
	active_layer_id = id
	active_layer[active_layer_id].visible = true
	SceneManager.fade_in({"pattern": "horizontal","speed":5,"invert_on_leave":false})


func _on_multiplayer_pressed() -> void:
	#await play_anim("fade_out")
	Event.is_multiplayer = true
	get_tree().change_scene_to_file("res://scen/gui/multi_play_core.tscn")

func _on_play_pressed():
	pressed(1)

func _on_settings_pressed() -> void:
	pressed(2)


func _on_credits_pressed() -> void:
	pressed(3)


func _on_menu_pressed() -> void:
	pressed(0)
	
@onready var audio_stream_player_2: AudioStreamPlayer = $AudioStreamPlayer2


const BOOM = preload("res://audio/sfx/boom.ogg")

func _on_fun_mode_toggled(toggled_on: bool) -> void:
	Event.userdata.fun_mode = toggled_on
	Event.userdata.save()
	Event.play_Gsfx(BOOM)


func _on_line_edit_text_changed(new_text: String) -> void:
	text_mesh.mesh.text = new_text
	audio_stream_player_2.play()


func _on_locale_item_selected(index: int) -> void:
	match index:
		0: TranslationServer.set_locale("en");Event.userdata.locale = "en"
		1: TranslationServer.set_locale("ru");Event.userdata.locale = "ru"
		2: TranslationServer.set_locale("uk");Event.userdata.locale = "uk"
	Event.userdata.save()
