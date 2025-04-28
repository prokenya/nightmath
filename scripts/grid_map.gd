@tool
extends GridMap
var node

const door = preload("res://scen/assets/door2_f.tscn")
const stair = preload("res://scen/assets/stairs_block.tscn")
var stairs
var doors
@export var replace: bool = false:
	set(value):
		replace = value
		if Engine.is_editor_hint():
			check_and_replace()
	get():
		return replace

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Gmap-activate!")

func check_and_replace():
	doors = get_used_cells_by_item(34)
	stairs = get_used_cells_by_item(36)
	if replace:
		tile_replace(doors, door, "door")
		tile_replace(stairs, stair, "stair")
	else:
		tile_rollback("door", 34)
		tile_rollback("stair", 36)


func tile_replace(cell_arr: Array, inst: PackedScene, inst_name: String) -> void:
	for cell in cell_arr:
		add_new_object(Vector3(cell.x, cell.y, cell.z), inst, inst_name)

func add_new_object(cell_pos: Vector3, inst: PackedScene, inst_name: String) -> Node:
	var new_inst = inst.instantiate()
	var world_pos = map_to_local(cell_pos)
	
	new_inst.global_transform.origin = world_pos
	new_inst.basis = get_cell_item_basis(cell_pos)
	# Удаляем тайл из GridMap
	set_cell_item(cell_pos, -1)

	# Добавляем объект в сцену
	add_child(new_inst)
	new_inst.set_owner(get_tree().edited_scene_root)
	new_inst.name = inst_name
	return new_inst


func tile_rollback(inst_name: String, tile_id: int) -> void:
	var to_remove = []
	for child in get_children():
		if inst_name in child.name:
			print(child.name)
			to_remove.append(child)
			set_cell_item(local_to_map(child.global_transform.origin), tile_id,get_orthogonal_index_from_basis(child.basis))
	for node in to_remove:
		node.queue_free()
