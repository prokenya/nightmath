extends ItemList


@onready var line_edit: LineEdit = %LineEdit
var attempt_counter:int = 0
@onready var sub_viewport_container: SubViewportContainer = %SubViewportContainer
@onready var warning: Label = %warning
@onready var tween = create_tween()

var warning_texts:Dictionary = Event.data.in_code_localisation

@onready var item_list: ItemList = $"."
var args = {"spawn_point": Vector3(0,100,0) }
var base_prefs:bool = false
var level_index:int 

func _ready():
	var username = Event.get_username()
	print(username)

	line_edit.text = username
	tween.stop()
	#for i in len(tscn_files):
		#item_list.add_item(tscn_files[i].replace("res://scen/levels/",""),
		#load("res://textures/1182467.160.webp"))


func _on_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	level_index = index

func _on_check_box_2_toggled(toggled_on: bool) -> void:
	base_prefs = toggled_on

#func _on_button_pressed() -> void:
	#if Event.is_multiplayer == false:
		#if base_prefs == true:
			#args["world"] = tscn_files[level_index]
			#Event.start_world_args = args
		#else:Event.start_world_args = {"name":"world1"}
		#SceneManager.change_scene(tscn_files[level_index],
		 #{"pattern": "curtains","invert_on_leave": false,"wait_time": 1})

func _on_play_pressed() -> void:
	Event.player_name = line_edit.text
	Event.start_world_args = {"name":"world2"}
	var pname =  line_edit.text
	
	if line_edit.text != "":
		if !pname in Event.userdata.players_names:
			Event.userdata.players_names.append(line_edit.text)
			Event.userdata.save()
		else:
			show_warning(warning_texts[Event.userdata.locale][1])
			return
		attempt_counter = 0
		SceneManager.change_scene(Event.load_scene("res://scen/levels/world2.tscn"),
		 {"pattern": "curtains","invert_on_leave": false,"wait_time": 1})
	else:
		attempt_counter += 1
		line_edit.add_theme_color_override("font_placeholder_color", Color(randf(), randf(), randf()))
	if attempt_counter > 5:
		show_warning(warning_texts[Event.userdata.locale][0])
func show_warning(warning_text) -> bool:
	if Event.userdata.fun_mode:
		Event.OSalert(warning_text)
		return true
	if tween == null or !tween.is_running():
		warning.text = warning_text
		tween = create_tween()  # Create a new tween instance
		await tween.tween_property(sub_viewport_container, "modulate", Color("#000000"), 2)
		await tween.tween_property(warning, "modulate", Color("#ffffff"), 3)
		await tween.tween_property(warning, "modulate", Color("#00000000"), 3)
		await tween.tween_property(sub_viewport_container, "modulate", Color("#ffffff"), 2)
		await tween.finished
		return true
	return false
		
		
