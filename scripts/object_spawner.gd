extends Node3D

@onready var objects_spawner: MultiplayerSpawner
func _ready() -> void:
	if inworld == true and Event.is_multiplayer == true:
		queue_free()
	if Event.is_multiplayer == true and inworld == false:
		objects_spawner = $OBJECTS_SPAWNER
		print_debug(objects_spawner)
		var items = InventoryManager.items
		for key in items.keys():
			objects_spawner.add_spawnable_scene(items[key][0])
	Event.connect("spawn_obj",spawn_obj)
@export var inworld:bool=false

var ignored_save_idx:Array[int] = []

func save_obj(path) -> bool:
	var objects = get_children()
	var objsdata:Array
	for object in objects:
		if object.get("item_id") != null:
			if object.item_id in ignored_save_idx:
				continue
			var objdata = {
		"spawn_obj_id": object.item_id,
		"obj_position": object.position,
		"obj_rotation": object.rotation,
		"obj_scale": Vector3(1,1,1),
		"amount": 1,
		"impulse": Vector3(0, 0, 0),
		"custom_properties":get_custom_properties(object)
		}
			objsdata.append(objdata)
	Event.userdata.level_objects[path] = objsdata
	Event.userdata.save()
	return true

func load_obj(path) -> String:
	if Event.userdata.level_objects.is_empty():
		return "level_objects is_empty"
	var objects_data = Event.userdata.level_objects.get(path)
	if objects_data == null:
		return "objects_data is_empty"
	for child in get_children():
		child.queue_free()
	for object_data in objects_data:
		spawn_obj(object_data)
	return "loaded" + str(objects_data)

func get_custom_properties(object: Node) -> Dictionary:
	if object.get("custom_properties") == null:
		return {}
	var cp = object.custom_properties
	var dictionary_custom_properties:Dictionary
	for property in cp:
		#print(property+ "|" + str(object.get(property)))
		dictionary_custom_properties[property] = object.get(property)
	return dictionary_custom_properties
		
func set_custom_properties(object: Node, properties: Dictionary) -> bool:
	if properties.is_empty():
		return false
	if object.get("custom_properties") == null:
		return false
	object.set("custom_properties",properties.keys()) 
	for property in properties.keys():
		if object.get(property) != null:
			object.set(property, properties[property])
	return true

func spawn_obj(data: Dictionary):
	if not data.has("spawn_obj_id"):
		data["spawn_obj_id"] = 0
	if not data.has("obj_position"):
		data["obj_position"] = Vector3(0, 0, 0)
	if not data.has("obj_rotation"):
		data["obj_rotation"] = Vector3(0, 0, 0)
	if not data.has("obj_scale"):
		data["obj_scale"] = Vector3(1, 1, 1)
	if not data.has("amount"):
		data["amount"] = 1
	if not data.has("impulse"):
		data["impulse"] = Vector3(0, 0, 0)
	if not data.has("pl_id"):
		data["pl_id"] = 255
	if not data.has("inventory"):
		data["inventory"] = false
	if not data.has("custom_properties"):
		data["custom_properties"] = {}
	if Event.is_multiplayer == true:
		if multiplayer.is_server():
			spawn_objs.call_deferred(data)
		else:
			spawn_objrpc.rpc(data)
			
	else:
		spawn_objs.call_deferred(data)

@rpc("reliable","call_remote","any_peer")
func spawn_objrpc(data: Dictionary):
	spawn_objs.call_deferred(data)

func spawn_objs(data: Dictionary):
	var dropped_item_scene
	var dropped_item_sub_scenei
	var dropped_item_sub_scene = InventoryManager.items[data["spawn_obj_id"]][4]
	
	if not data["inventory"]:
		dropped_item_scene = InventoryManager.items[data["spawn_obj_id"]][0]
	else:
		dropped_item_scene = InventoryManager.items[data["spawn_obj_id"]][1]
	for i in range(data["amount"]):
		if dropped_item_sub_scene != null:
			dropped_item_sub_scenei = dropped_item_sub_scene.instantiate()
		var dropped_item = dropped_item_scene.instantiate()
		dropped_item.position = data["obj_position"]
		dropped_item.rotation = data["obj_rotation"]
		dropped_item.scale = dropped_item.scale * data["obj_scale"]
		
		if !data["custom_properties"].is_empty():
			var status =  set_custom_properties(dropped_item,data["custom_properties"])
			Event.printc(str(data["custom_properties"])+ " setting -> " + str(status),Color.GREEN if status else Color.RED)
			
		if data.has("spawn_parent"):
			data["spawn_parent"].add_child(dropped_item)
		else:
			if InventoryManager.items.has(data["spawn_obj_id"]): # Проверяем, существует ли объект по ключу
				var item_array = InventoryManager.items[data["spawn_obj_id"]]
				if item_array is Array and item_array.size() > 5: # Проверяем, что это массив и в нём достаточно элементов
					if item_array[5] != null:
						dropped_item.item_name = item_array[5]
			add_child(dropped_item,true)
			if dropped_item_sub_scene != null:
				dropped_item.item_id = data["spawn_obj_id"]
				dropped_item.add_child(dropped_item_sub_scenei,true)
			
		if dropped_item is RigidBody3D:
			dropped_item.linear_velocity = data["impulse"]
			dropped_item.angular_velocity = data["impulse"]
		
	#Event.printc(str(data["pl_id"]) + " s " + str(data["spawn_obj_id"]), Color.GREEN)
