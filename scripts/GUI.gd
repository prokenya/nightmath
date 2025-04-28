extends Control

#@onready var use = $use
@onready var pick_up: Button = $pick_up
@onready var fire: TouchScreenButton = $VBoxContainer2/fire
@onready var useitem: TouchScreenButton = $VBoxContainer2/useitem
@onready var enemy_control: HBoxContainer = $ENEMY_CONTROL
@onready var item_name: Label = $item_name
var previous_item_name = ""

@onready var shaders: CanvasLayer = $shaders

@onready var color_sh: ColorRect = $shaders/ColorRect

@onready var hp = $hp
var item_id
var control_id
@onready var gui = $"."
@onready var menu = $"../../ui_b"
@onready var pos: Label = $pos
@onready var player_node
@onready var elements_to_del_mobile:Array = [$"Virtual Joystick",$VBoxContainer,$VBoxContainer2,pick_up,$Button,useitem]
@onready var elements_to_del_PC:Array = [$hints]
@onready var hints: Array = $hints.get_children()
var is_paused = false
var events_dict:Dictionary = {9:["event_2",1]}

func pressed():
	if gui.visible == true:
		gui.visible = false
		menu.visible = true
	else:
		gui.visible = true
		menu.visible = false
	is_paused = not is_paused
	Event.in_gui = is_paused

func _ready():
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	if Event.platform == "PC":
		for item in elements_to_del_mobile:
			item.queue_free()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		for item in elements_to_del_PC:
			item.queue_free()
	Event.connect("menu", pressed)
	Event.connect("_active_item",active_item)
	player_node = get_parent().get_parent().get_parent()
	

func _exit_tree() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_SLASH):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Event.emit_signal("menu")
	if Event.platform == "PC" and !Event.in_gui:
		if Input.is_action_just_pressed("jump_move"):
			_on_touch_screen_button_pressed()
		if Input.is_action_just_pressed("interact"):
			_on_fire_pressed()
		if Input.is_action_just_released("mouse_left"):
			_on_useitem_pressed()
		if Input.is_action_just_pressed("F-KEY") and item_id not in [-1,-3,-4]:
			_on_pick_up_pressed()


func _physics_process(delta: float) -> void:
	hp.text = "HP:" + str(Event.hp_char)
	pos.text = "pos:" + str(round(player_node.position))
	update_ids()

func update_ids():
	item_id = player_node.picked_item_id
	control_id = player_node.picked_item_control
	#print(control_id)
	if Event.platform != "PC":
		if item_id == -1:
			pick_up.visible = false
		else:
			pick_up.visible = true
		if item_id in [-3,-4]:
			pick_up.visible = false
			fire.visible = true
		else:
			fire.visible = false
	elif Event.userdata.show_hints:
		if item_id not in [-1,-3,-4]:
			hints[0].visible = true
		else:
			hints[0].visible = false
		if item_id in [-3,-4]:
			hints[1].visible = true
		else:
			hints[1].visible = false
	update_item_name(player_node.picked_item)

var tween

func update_item_name(picked_item):

	var current_item_name := ""

	if picked_item != null and "item_name" in picked_item:
		current_item_name = picked_item["item_name"]

	if current_item_name == previous_item_name:
		return

	if is_instance_valid(tween):
		tween.kill()
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)

	if current_item_name != "":
		item_name.text = current_item_name
		previous_item_name = current_item_name
		tween.tween_property(item_name, "self_modulate", Color("ffffff"), 1)
	else:
		tween.tween_property(item_name, "self_modulate", Color("ffffff00"), 1)
		previous_item_name = ""





@onready var visibleids = {
	[7, 9, 12]: useitem,
	[8]: enemy_control
}

func active_item(id,custom_properties):
	for node in visibleids.values():
		if is_instance_valid(node):
			node.visible = false

	if id != -1:
		for key in visibleids.keys():
			if id in key:
				if is_instance_valid(visibleids[key]):
					visibleids[key].visible = true
					break

func _on_touch_screen_button_pressed():
	Event.emit_signal("jump")


func _on_fire_pressed():
	var mpp = -1
	if Event.is_multiplayer == true:
		mpp = player_node.mpp.player_index
	if control_id != -1 and player_node.picked_controller_id == -1:
		var data = {
		"control_id": control_id,
		"controller_id":player_node.control_item_id,
		"controlled_object_type":player_node.picked_controlled_object_type,
		"multiplayer_index":mpp
		}
		Event.set_control(data)
		print("Applying control for ID:",control_id)
	if item_id == -3:
		player_node.picked_item.open()
	if item_id == -4:
		player_node.picked_item.use()
		


func die(text:String):
	var tween = create_tween()
	shaders.visible = true
	Event.OSalert(text)
	if Event.world.enemy:
		Event.world.enemy.queue_free()
	tween.tween_property(color_sh.material, "shader_parameter/pixel_size", 50, 20)
	await tween.finished
	OS.crash("error")
	#Event.world.switch_scene(false,"res://scen/gui/credits.tscn",false)
	
func _on_pick_up_pressed():
	#print(Event.avable_items_id,"\n",item_id)
	if item_id in Event.avable_items_id or Event.avable_items_id[0] == -2:
		if Event.is_multiplayer == true:
			Event.emit_signal("pick_up",Event.mpp_index)
		else:
			Event.emit_signal("pick_up",-1)
#item = null, drop: bool = false, slot_id: int = -1, item_amount: int = 1, id: int = -33
func _on_useitem_pressed() -> void:
	if player_node.hp <= 0: return
	var aid =  player_node.active_item_id
	if aid in events_dict.keys():
		Event.emit_signal("remove_item",null,false,-1,1,-33)
		player_node.a_stream_player.switch_to_clip(events_dict[aid][1])
		#if !Event.completion_events.has(events_dict[aid][0]):
			#if Event.platform == "PC":
				#Event.emit_signal("start_dialogue","task",true,1)
			#else:
				#Event.emit_signal("start_dialogue","START",false,-1)
				
		Event.set_event(events_dict[aid][0])
	Event.emit_signal("on_fire")
