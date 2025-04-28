extends RigidBody3D
@export var item_id = 0
@export var item_name:String
@export var has_audio:bool = true
@export var custom_properties:Array
@onready var audio:Array[AudioStream] = [preload("res://audio/sfx/Coin_Drop on Table_3.wav"),
preload("res://audio/sfx/body-falling-to-ground-100474.mp3"),preload("res://audio/sfx/papers-falling-.mp3"),
preload("res://audio/sfx/truba-upala.mp3")]
@export var current_stream:int = 0
@onready var audio_player = AudioStreamPlayer3D.new()

func _ready():
	if has_audio:
		self.contact_monitor = true
		self.max_contacts_reported = 1
		self.continuous_cd = true
		audio_player.max_distance = 100
		audio_player.bus = "SFX"
		add_child(audio_player)
		self.connect("body_entered",_on_body_entered)

func play_sound():
	audio_player.stream = audio[current_stream]
	audio_player.play()

var first_contact:bool = true

func _on_body_entered(body: Node) -> void:
	if first_contact:
		first_contact = false
		return
	play_sound()
	#print(body)
