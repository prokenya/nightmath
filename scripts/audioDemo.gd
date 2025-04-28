extends Control

@onready var dialogue_box = $VBoxContainer/DialogueBox
@onready var audio_player = $AudioStreamPlayer
@onready var animation_player: AnimationPlayer = $VBoxContainer/AnimationPlayer
@export var dialogue_data:Dictionary = {
	"en":DialogueData,
	"ru":DialogueData,
	"uk":DialogueData
}
#@onready var color_rect: ColorRect = $ColorRect
@onready var texture_rect: TextureRect = %TextureRect
var data = Data.load_or_create()
@export var tasks:Dictionary
var new_tasks:Dictionary = {
	10: {
		"Answers": ["Âîçìîæíî, äà.", "Íåò, ýòî îøèáêà.", "¯_(ツ)_/¯", "Êòî çíàåò..."],
		"CorrectAnswerIndex": 0,
		"Difficulty": ";",
		"Task": {
			"en": "Ðàçâå èòî íå ïðàâäà?",
			"uk": "Ðàçâå èòî íå ïðàâäà?",
			"ru": "Ðàçâå èòî íå ïðàâäà?"
		},
		"Type": "Teacher"
	}
}
@onready var font: TextureRect = %font
var last_idx:String
var last_task_id:int
var has_img:bool = false
var start_time: int = 0

func start_timer():
	start_time = Time.get_ticks_msec()

func stop_timer():
	if start_time == 0:
		#print("Таймер не был запущен!")
		return -1
	var elapsed_time = Time.get_ticks_msec() - start_time
	var sec = elapsed_time / 1000.0
	#print("Ответ занял: ", sec, " секунд")
	return sec

func _ready():
	Event.register_object("dialogs",self)
	dialogue_box.data = dialogue_data[Event.userdata.locale]
	tasks = data.tasks.duplicate(true)
	#tasks.merge(new_tasks,true)
	#data.tasks = tasks
	#data.save()
	#print(tasks)
	Event.connect("start_dialogue",start_dialogue)
	#breakpoint
	# connect to the char_displayed signal which is emitted everytime a character is displayed in the dialoguebox
	dialogue_box.custom_effects[0].char_displayed.connect(_on_char_displayed)
	#start_dialogue("task",false,1)

@export var avatars:Array[Texture] = [preload("res://dialogue/avatar_yellow_frame.png"),
preload("res://dialogue/avatar_red_frame.png"),preload("res://dialogue/avatar_died.png")]

func start_dialogue(idx:String,kui:bool = false,task_id:int = -1):
	last_idx = idx
	last_task_id = task_id
	var locale = TranslationServer.get_locale()
	font.visible = false
	Event.set_event("event_4")
	dialogue_box.characters[0].name= Event.player_name
	dialogue_box.start_id = idx
	if idx == "mono":
		dialogue_box.characters[1].image = avatars[2]
	if idx == "task":
		if task_id == 10:
			dialogue_box.characters[1].image = avatars[1]
		start_timer()
		dialogue_box.variables["task_text"] = tasks[task_id]["Task"][locale]
		var answers = tasks[task_id]["Answers"]
		var correct_answer_index = tasks[task_id]["CorrectAnswerIndex"]
		var correct_answer = answers[correct_answer_index]
		var shuffled_answers = answers.duplicate(true)
		shuffled_answers.shuffle()
		var i = 1
		for answer in shuffled_answers:
			dialogue_box.variables["Answer" + str(i)] = str(answer)
			i += 1
		dialogue_box.variables["CorrectAnswer"] = str(correct_answer)
		#print(shuffled_answers)
		#print(correct_answer)
		if tasks[task_id].has("img"):
			texture_rect.texture = tasks[task_id]["img"]
			animation_player.play("show")
			has_img = true
		else:
			has_img = false
	dialogue_box.start()
	self.visible = true
	Event.in_gui = kui
	#color_rect.visible = true

func stop_dialogue():
	dialogue_box.stop()

func _on_char_displayed(idx):
	# you can use the idx parameter to check the index of the character displayed
	
	audio_player.__play_sound()


func _on_dialogue_box_dialogue_ended() -> void:
	Event.close_event("event_4",false)
	Event.in_gui = false
	if has_img:
		animation_player.play("hide")
		has_img = false
	else:
		self.visible = false
	
	#color_rect.visible = false
func time_chek() -> bool:
	var sec = stop_timer()
	if sec != -1:
		var coficit:float
		var Difficulty = tasks[last_task_id]["Difficulty"]
		match Difficulty:
			"ez": coficit = 1.0
			"medium": coficit = 1.2
			"hard": coficit = 1.5
			_: coficit = 1.0
		var max_time = 10
		var probability = ((max_time - sec) / max_time) * coficit
		probability = clamp(probability, 0.0, 1.0)
		if randf() < probability:
			Event.OSalert(Event.data.in_code_localisation[Event.userdata.locale][6])
			await get_tree().create_timer(3).timeout
			if 	Event.world.enemy:
				Event.world.enemy.set_used_tasks(true)
				Event.world.enemy_rage()
				return true
	return false

#region events

func event_1(stop,idx:String,kui:bool = false):
	if !stop:
		start_dialogue(idx,kui)
	#else:
		#stop_dialogue()
func event_4(stop:bool,id:int):
	if !stop:
		pass
	else:
		#print("stop_event")
		stop_dialogue()
#endregion


func _on_dialogue_box_dialogue_signal(value: String) -> void:
	if value == "false":
		Event.world.enemy_rage()
	else: 
		if await time_chek() == false:
			Event.world.enemy_reset(true)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hide":
		font.visible = false
		texture_rect.texture = null
		self.visible = false
		
