@tool
extends Node3D

#item
var item_name
@export var item_id = 11
var custom_properties:Array = ["x_range","resolution","use_collision",
"time_for_point","visualize_when_spawned","random_color","current_func_index"]

@onready var path_3d: Path3D = $Path3D
@onready var draw_point: MeshInstance3D = $draw_point
@onready var csg_polygon: CSGPolygon3D = $CSGPolygon3D
@export var x_range: float = 100.0  # Диапазон значений X
@export var resolution: int = 100  # Количество точек для каждой функции
@export var use_collision: bool = false
@export var time_for_point: float = 0.05
@export var visualize_when_spawned: bool = false
@export var random_color: bool = false
@export var wait_time:float = 1.0
@export var current_func_index: int = 0
	#set(value):
		#current_func_index = value
		#if Engine.is_editor_hint():
			#path_3d.curve = path_3d.curve.duplicate() as Curve3D
			#await visualize_functions(current_func_index)
	#get():
		#return current_func_index

# Массив с функциями
var functions: Array[Callable] = [
	func(x: float) -> Vector3: return Vector3(x, x * 2, 0),
	func(x: float) -> Vector3: return Vector3(x, x * x, 0),
	func(x: float) -> Vector3: return Vector3(x, sin(x), 0),
	func(x: float) -> Vector3: return Vector3(x, x * sin(x), 0),
	func(x: float) -> Vector3: return Vector3(x, sin(x) * abs(10-x), 0),
	func(x: float) -> Vector3: return Vector3(x * cos(x), x * sin(x), x),
	func(x: float) -> Vector3: 
	var a = 100.0
	var b = 110.0
	return Vector3((a - b) * cos(x) + b * cos((a/b - 1) * x), 
				   (a - b) * sin(x) - b * sin((a/b - 1) * x), 
				   0)

]


func _ready() -> void:
	if Engine.is_editor_hint():return
	if visualize_when_spawned:
		path_3d.curve = path_3d.curve.duplicate() as Curve3D
		visualize_functions(current_func_index)

func visualize_functions(func_index:int) -> bool:
	await get_tree().create_timer(wait_time).timeout
	if random_color:
		var unique_material = csg_polygon.material_override.duplicate() as Material
		unique_material.emission = Color(randf(), randf(), randf())
		csg_polygon.material_override = unique_material
		
	csg_polygon.use_collision = use_collision
	csg_polygon.collision_layer = 1
	draw_point.visible = true
	var curve = path_3d.curve
	curve.clear_points()  # Очистка старых точек

	var f = functions[func_index]
	var points: Array[Vector3] = []
	
	for i in range(resolution + 1):
		var t = i / float(resolution)
		var x = -x_range + t * 2.0 * x_range
		var point = f.call(x) * Vector3(scale.x, scale.y, scale.z)
		points.append(point)

	# Добавляем точки в кривую
	for point in points:
		await get_tree().create_timer(time_for_point).timeout
		curve.add_point(point)
		draw_point.position = point
	draw_point.hide()
	return true
