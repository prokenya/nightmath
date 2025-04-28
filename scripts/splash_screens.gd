extends Control

@onready var texture_rect: TextureRect = $TextureRect
@export var textures:Array[CompressedTexture2D]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for texture in textures:
		await change_screen(texture)
	Event.load_scene("res://scen/levels/world2.tscn")
	change_scene()

func _input(event):
	if Input.is_anything_pressed():
		change_scene()

func change_scene():
	if Event.userdata.save_exit:
		Event.userdata.save_exit = false
		Event.userdata.save()
		get_tree().change_scene_to_file("res://scen/levels/world3.tscn")
		return
	get_tree().change_scene_to_file("res://scen/gui/menu.tscn")

func change_screen(texture) -> bool:
	var tween = create_tween()
	tween.tween_property(texture_rect, "self_modulate", Color("#ffffff00"), 1)
	await tween.finished

	texture_rect.texture = texture
	
	tween = create_tween()
	tween.tween_property(texture_rect, "self_modulate", Color("#ffffffff"), 1)
	await tween.finished

	return true

	
	
