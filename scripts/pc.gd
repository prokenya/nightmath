extends StaticBody3D

@onready var label_3d: Label3D = $"../Label3D"
@export var item_id = -4
@export var item_name: = "sreen"
func use():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Event.OSalert(Event.data.in_code_localisation[Event.userdata.locale][3] + Event.player_name,"LEo")
	await get_tree().create_timer(1).timeout
	Event.OSalert("rm " + Event.player_name,"LEo")
	await get_tree().create_timer(1).timeout
	Event.userdata.save_exit = true
	Event.userdata.save()
	OS.crash("error")
