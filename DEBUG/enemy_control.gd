extends HBoxContainer

var c_state: = 0
var c_oneshot_state: = 0
var toggled:bool = false
var c_vision:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_state_item_selected(index: int) -> void:
	Event.emit_signal("set_animation",index,-1,toggled,c_vision)
	c_state = index


func _on_oneshot_state_item_selected(index: int) -> void:
	Event.emit_signal("set_animation",c_state,index,toggled,c_vision)


func _on_kill_ai_toggled(toggled_on: bool) -> void:
	toggled = toggled_on
	Event.emit_signal("set_animation",c_state,-1,toggled,c_vision)


func _on_kill_vis_toggled(toggled_on: bool) -> void:
	c_vision = toggled_on
	Event.emit_signal("set_animation",c_state,-1,toggled,c_vision)
