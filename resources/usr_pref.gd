class_name UserPref extends Resource

@export_range(0, 1, .05) var SFX_lv: float = 0.5
@export_range(0, 1, .05) var music: float = 0.5
@export var locale:String = "null"
@export var resolution:int = 0
@export var ui_scale:int = 2

@export_range(0,1,.05) var sensitivity: float = 0.5
@export var MSAA: int = 0
@export var VsyncOption:int = 0
@export var cam_ch: bool = true
@export var show_hints: bool = true
@export var save_exit:bool = false

@export var freejump_s: bool = false
@export var infinite_hp: bool = false

@export var fun_mode: bool = false
@export var shadows: bool = false
@export var high_graphics: bool = false

@export var inventory_items: Dictionary = {}
@export var level_objects:Dictionary 
@export var players_names:Array[String]


@export var first_run:bool = true

func save() -> void:
	ResourceSaver.save(self, "user://gamedata.tres")

static  func load_or_create() -> UserPref:
	var res: UserPref = load("user://gamedata.tres") as UserPref
	if !res:
		res = UserPref.new()
	return res
