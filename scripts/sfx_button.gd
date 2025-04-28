class_name sfx_button
extends BaseButton

@onready var stream_player = AudioStreamPlayer.new()
@export var stream:AudioStream = preload("res://audio/sfx/Interface_Bleeps_OGG/Complete_02.ogg")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if stream != null:
		add_child(stream_player)
		stream_player.stream = stream
		stream_player.bus = "SFX"
		stream_player.volume_db = -10
		connect("button_down",play)

func play():
	stream_player.play()
