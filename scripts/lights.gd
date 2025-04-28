@tool
extends Node3D

var lights:Array
var global_light_energy_scale:float
@export var Worldenvirement:WorldEnvironment

@export var on_light := false :
	set (value):
		on_light = value
		if Engine.is_editor_hint():
			o_light()
	get():
		return on_light

func o_light():
	find_lights_in_group()
	for light in lights:
		light.visible = on_light

func _ready() -> void:
	if Engine.is_editor_hint():return
	find_lights_in_group()
	Event.connect("update_wold_setings",update_light)
	Event.register_object("env",self)
	await get_tree().create_timer(1).timeout
	update_light()

#region events
@onready var last_value = Worldenvirement.environment.tonemap_white

func event_2(stop,value):
	var tween = create_tween()
	if stop:
		tween.tween_property(Worldenvirement.environment,"tonemap_white",last_value,5)
		tween.tween_property(Worldenvirement.environment,"adjustment_saturation",last_value,5)
		#Worldenvirement.environment.tonemap_white = last_value
	else:
		tween.tween_property(Worldenvirement.environment,"tonemap_white",value,5)
		tween.tween_property(Worldenvirement.environment,"adjustment_saturation",5,5)
		
		
		#Worldenvirement.environment.tonemap_white = value
	#func

#endregion



func update_light():
	if Event.userdata.shadows:
		visible = false
		on_light = true
		o_light()
		#Worldenvirement.environment.background_color = Color.BLACK
		
	else:
		visible = true
		on_light = false
		o_light()
		#Worldenvirement.environment.background_color = Color("#323232")
	#for light in lights:
		#light.shadow_enabled = Event.userdata.shadows
	Worldenvirement.environment.set_glow_enabled(Event.userdata.high_graphics)
			

func find_lights_in_group() -> void:
	lights = []
	var scene_tree = get_tree()
	if scene_tree.has_group("light"):
		for node in scene_tree.get_nodes_in_group("light"):
			lights.append(node)

func switch_bl():
	pass
