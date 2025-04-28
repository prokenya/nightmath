extends CanvasLayer


@onready var button: TextureButton = $Control/VBoxContainer/HBoxContainer/Button
@onready var line_edit: LineEdit = $Control/VBoxContainer/HBoxContainer/LineEdit
@onready var label: Label = $Control/VBoxContainer/HBoxContainer/Label
@onready var lauthor: Label = $Control/VBoxContainer/author


@export var in_use:bool = false
@export var text:String

signal submitted(text:String)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close_iteraction()
	Event.iteraction_menu = self

func set_iteraction(type:int,text:String = "",author:String = "//"):
	if in_use:
		return false
	in_use = true
	Event.in_gui = true
	self.visible = true
	lauthor.text = author
	lauthor.show()
	match type:
		0:label.show();label.text = text
		1:line_edit.show();button.show()
		2:line_edit.show();button.show();label.show()
		3:button.show();label.show()

func close_iteraction(submit:bool = false):
	if !in_use:
		return false
	Event.in_gui = false
	if submit:
		emit_signal("submitted",text)
	self.visible = false
	in_use = false
	line_edit.text = ""
	label.text = ""
	lauthor.text = ""
	lauthor.hide()
	line_edit.hide()
	button.hide()
	label.hide()

func _on_button_button_up() -> void:
	text = line_edit.text
	close_iteraction(true)
	


func _on_line_edit_text_submitted(new_text: String) -> void:
	text = line_edit.text
	close_iteraction(true)
