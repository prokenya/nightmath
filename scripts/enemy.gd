extends CharacterBody3D

# === CONSTANTS ===
const JUMP_VELOCITY = 4.5
const SPEED_IDLE = 0
const SPEED_WALK = 2
const SPEED_RUN = 3.6
const GORE_WET_4 = preload("res://audio/sfx/Gore_Wet_4.wav")
# === ENUMS ===
enum State { IDLE, WALK, RUN, SITTING, CROWLING }
enum oneshot_state { HIT, OPEN_DOOR, STAND_TO_SIT, SIT_TO_STAND, SLEEP }

# === EXPORTED VARIABLES ===
@export var damage: int = 0
@export var in_rage: bool = false
@export var current_state: State = State.IDLE
@export var current_oneshot_state = oneshot_state.HIT
@export var reycast_angle: float = 50
@onready var plr_3: Node3D = $plr3
@export var streams:Array[AudioStream]
# === NODE REFERENCES (ONREADY) ===
@onready var navigation_agent = $NavigationAgent3D
@onready var players = []
@onready var current_target: Node3D = $current_target
@onready var target = current_target
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var memory: Timer = $memory
@onready var area_3d: Area3D = $Area3D
@onready var reycasts = [$"reycastsf/1", $"reycastsf/2", $"reycastsf/3", $"reycastsf/4"]
@onready var reycastsf: Node3D = $reycastsf
@onready var old_collision_mask = collision_mask
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D


# === INTERNAL VARIABLES ===\]
var custom_properties:Array[String] = ["correct_streak","used_tasks","hp"]
var correct_streak:int = 0
var current_task_id:int = -1
var used_tasks:Array[int] = []
var item_id = -1
var last_target_pos: Vector3 = Vector3.ZERO
var random_points: Array = []
var area_parent: Node3D
var user_control: bool = false
var remove_vision: bool = false
var peaceful_time:int = 1
var SPEED = SPEED_WALK
var rotation_time = 0.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var hp = 1
var tween
var last_spawn_point
var area_3monitoring: bool = true :
	set(value):
		area_3monitoring = value
		$Area3D.monitoring = area_3monitoring
	get():
		return area_3monitoring
func _ready() -> void:
	find_players_in_group()
	find_points_in_group()
	Event.connect("_on_player_connected",on_player_connected)
	Event.connect("set_animation",set_animation)

func apperase(time:float) -> bool:
	remove_vision = true
	$Area3D.monitoring = false
	await get_tree().create_timer(time).timeout
	$Area3D.monitoring = true
	remove_vision = false
	return true

func set_animation(s,oneshot_s,userc:bool=false,remove_vis:bool = false):
	user_control = userc
	current_state = s
	if oneshot_s != -1:
		current_oneshot_state = oneshot_s
		handle_ONESHOTanim()

func on_player_connected():
	find_players_in_group()

func handle_anim():
	match current_state:
		State.IDLE:
			animation_tree.set("parameters/MOVMENT/transition_request","IDLE")
		State.WALK:
			animation_tree.set("parameters/MOVMENT/transition_request","WALK")
		State.RUN:
			animation_tree.set("parameters/MOVMENT/transition_request","RUN")
		State.SITTING:
			animation_tree.set("parameters/MOVMENT/transition_request","SITTING")
		State.CROWLING:
			animation_tree.set("parameters/MOVMENT/transition_request","CROWLING")

func handle_ONESHOTanim():
	match current_oneshot_state:
		oneshot_state.HIT:
			animation_tree.set("parameters/HIT/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		oneshot_state.OPEN_DOOR:
			animation_tree.set("parameters/OPEN_DOOR/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		oneshot_state.STAND_TO_SIT:
			animation_tree.set("parameters/STAND_SIT/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		oneshot_state.SIT_TO_STAND:
			animation_tree.set("parameters/SIT_STAND/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		oneshot_state.SLEEP:
			animation_tree.set("parameters/SLEEP/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
			

func find_points_in_group() -> void:
	random_points = []
	var scene_tree = get_tree()
	if scene_tree.has_group("random_points"):
		for node in scene_tree.get_nodes_in_group("random_points"):
			random_points.append(node)

func find_players_in_group() -> void:
	players = []
	var scene_tree = get_tree()
	if scene_tree.has_group("player"):
		for node in scene_tree.get_nodes_in_group("player"):
			players.append(node)

func change_target(targ,time_in_memory:float,skip:bool = false):
	if memory.is_stopped():
		memory.wait_time = time_in_memory
		target = targ
		memory.start()
		if target.is_in_group("player"):
			play_sound(0)
	if skip:
		memory.stop()
		memory.wait_time = time_in_memory
		target = targ
		memory.start()

func _on_memory_timeout() -> void:
	target = current_target

func set_random_current_target(waiting_time: float,exception_names: Array[String] = [],tp_to_ct:bool = false):
	if  random_points.is_empty():return
	var rand_points = random_points[0]
	var available_points = rand_points.get_children()
	var filtered_points = []
	for point in available_points:
		if point.name not in exception_names:
			filtered_points.append(point)
	available_points = filtered_points

	if available_points.size() <= 1:
		# Если только одна точка, вернуться к текущей позиции.
		print("Недостаточно точек для выбора новой цели.")
		return

	var new_target
	while true:
		var rand_point_id = randi_range(0, available_points.size() - 1)
		new_target = available_points[rand_point_id]
		if new_target.global_position != current_target.position:
			break  # Найдена новая точка, которая отличается от текущей.

	#print("Ожидание:", waiting_time, "с перед выбором новой цели.")
	await get_tree().create_timer(waiting_time).timeout
	current_target.position = new_target.global_position
	if tp_to_ct == true:
		position = current_target.position


func rotate_reycasts(delta):
	# Накопление времени
	rotation_time += delta

	# Вычисление угла
	var t = (sin(rotation_time) + 1) / 2
	var angle = lerp(-reycast_angle, reycast_angle, t)
	reycastsf.rotation = Vector3(0, deg_to_rad(angle), 0)
	
func _physics_process(delta):
	if user_control:
		navigation_agent.set_velocity(Vector3.ZERO)
		#rotation = Vector3.ZERO
		handle_anim()
		if global_transform.origin.distance_to(players[0].position) > 0.01:
			global_transform = global_transform.interpolate_with(global_transform.looking_at(players[0].position), delta * 3)
			rotation *= Vector3(0,1,1)
		return

	for ray in reycasts:
		if ray.is_colliding() and !user_control and current_state not in [State.SITTING]:
			var item = ray.get_collider()
			if item.is_in_group("player") and !remove_vision:
				# Запоминаем цель на указанное время
				change_target(item, 10,true)
				# Сбрасываем рейкасты в нулевую координату
				reycastsf.rotation = Vector3(0,0,0)
				if !navigation_agent.is_navigation_finished():
					if in_rage:
						current_state = State.CROWLING
					else:
						current_state = State.RUN
				else: current_state = State.IDLE
					
				break
			else:
				# Вращаем рейкасты, если нет игрока
				rotate_reycasts(delta)
				if !navigation_agent.is_navigation_finished():
					if in_rage:
						current_state = State.CROWLING
					else:
						current_state = State.WALK
		elif target == current_target:
			rotate_reycasts(delta)
	handle_anim()
	if target and !user_control:
		var plTransform = target.transform.origin
		plTransform.y = transform.origin.y - 0.5
		var curPos = global_position
		var next_pos = navigation_agent.get_next_path_position()
		var new_vel = (next_pos - curPos).normalized() * SPEED
		if target != current_target:
			look_at(plTransform, Vector3.UP)
		else:
			if global_transform.origin.distance_to(next_pos) > 0.01:
				global_transform = global_transform.interpolate_with(global_transform.looking_at(next_pos), delta * 3)
				rotation *= Vector3(0,1,1)
		if curPos.distance_to(plTransform) > 5000:
			SPEED = 0
		else:
			if current_state in [State.IDLE,State.SITTING]:
				SPEED = 0
			if current_state in [State.WALK]:
				SPEED = 2
			if current_state == State.RUN:
				SPEED = SPEED_RUN
			if current_state == State.CROWLING:
				SPEED = 5
		
		#push_rb()
		if navigation_agent.avoidance_enabled:
			navigation_agent.set_velocity(new_vel)
		else:
			_on_velocity_computed(new_vel)
			#velocity = velocity.move_toward(new_vel, .25)


func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity
	move_and_slide()

func op_tg_loc(target_loc):
	navigation_agent.set_target_position(target_loc)

func _process(delta):
	if target.global_position != last_target_pos:
		op_tg_loc(target.global_position)
		last_target_pos = target.global_position
		#print("update loc")
	if area_parent != null and area_parent.get("item_id") == -3 and !area_parent.is_open:
		area_parent.open(true)
		#current_oneshot_state = oneshot_state.OPEN_DOOR
		#handle_ONESHOTanim()

func _on_area_3d_area_entered(area: Area3D) -> void:
	area_parent = area.get_parent()
	if area_parent.is_in_group("player"):
		if "event_4" in Event.current_events:
			return
		play_sound(1)
		current_oneshot_state = oneshot_state.HIT
		handle_ONESHOTanim()
		area_parent.set_hp(damage)
		look_at(area_parent.transform.origin, Vector3.UP)
		await get_tree().create_timer(1).timeout
		Event.world.die(damage)

func set_hp(hp:int):
	self.hp -= hp
	current_oneshot_state = oneshot_state.SLEEP
	handle_ONESHOTanim()
	await get_tree().create_timer(4).timeout
	if self.hp <= 0:
		Event.world.switch_scene(false,"res://scen/gui/credits.tscn",false,0.2,false)
		queue_free()
		

func die(player:Node,dm,epoint) -> bool:
	last_spawn_point = epoint
	change_target(current_target,50,true)
	damage = 0
	in_rage = false
	if dm != 0:
		enemy_reset(null)
		return false
	elif dm == 0:
		current_task_id = ask_task()
		collision_mask = 0
		await get_tree().create_timer(2.2).timeout
		if current_task_id == -1:
			set_animation(3,-1,true,true)
			apperase(1000)
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			Event.world.players[0].kill_movment = true
			Event.OSalert("...","LEo")
			await get_tree().create_timer(1).timeout
			Event.OSalert(Event.data.in_code_localisation[Event.userdata.locale][4] + " " + Event.player_name,"LEo")
			await get_tree().create_timer(1).timeout
			Event.OSalert(Event.data.in_code_localisation[Event.userdata.locale][3] + " " + Event.player_name,"LEo")
			await get_tree().create_timer(1).timeout
			Event.play_Gsfx(GORE_WET_4)
			await get_tree().create_timer(1.3).timeout
			Event.world.switch_scene(false,"res://scen/levels/final.tscn",true,0.6,false)
			return true
		Event.emit_signal("start_dialogue","task",false,current_task_id)
	set_animation(3,-1,true,false)
	return true

func enemy_rage(enemy_point) -> bool:
	Event.close_event("event_4")
	damage = 1
	if tween:
		tween.kill()
	tween = create_tween()
	set_animation(State.IDLE,oneshot_state.SIT_TO_STAND,true)
	var point = enemy_point.position + Vector3(0,0,1)
	tween.tween_property(self,"position",point,2)
	await tween.finished
	set_animation(4,-1,false,false)
	in_rage = true
	play_sound(0)
	change_target(players[0],10,true)
	return true
	
func enemy_reset(enemy_point,correct:bool = false) -> bool:
	Event.close_event("event_4")
	damage = 0
	set_used_tasks(correct)
	if correct_streak == 3:
		Event.OSalert("3 correct streak","LEo")
		var data = {
		"spawn_obj_id": 12,
		"obj_position": self.position,
		"obj_rotation": Vector3.UP,
		"obj_scale": Vector3(1, 1, 1),
		"amount": 1,
		"impulse": Vector3(0, 0, 0),
		"pl_id": Event.mpp_index
		}
		Event.emit_signal("spawn_obj",data)
	change_target(current_target,0.1,true)
	if enemy_point == null:
		set_random_current_target(0.1,["1","2"],true)
		return false
	if enemy_point:
		if tween:
			tween.kill()
		tween = create_tween()
		var point = enemy_point.position + Vector3(0,0,+0.5)
		tween.tween_property(self,"position",point,2)
		set_animation(State.IDLE,oneshot_state.SIT_TO_STAND,true)
		apperase(20)
		set_random_current_target(0.1,["1","2"],false)
		await get_tree().create_timer(5).timeout
		set_animation(State.IDLE,-1)
	set_animation(1,-1,false,false)
	in_rage = false
	return true

func set_used_tasks(correct):
	if correct:
		used_tasks.append(current_task_id)
		current_task_id = -1
		correct_streak += 1
	else: correct_streak = 0

func ask_task() -> int:
	var ids: Array
	for i in range(1, 10):
		ids.append(i)
	for used_id in used_tasks:
		ids.erase(used_id)
	if !ids.is_empty():
		return ids.pick_random()
	return -1

		
func _on_area_3d_area_exited(area: Area3D) -> void:
	var area_p = area.get_parent()
	if area_p.get("item_id") == -3:
		if area_p.is_open:
			area_p.open(true)
	area_parent = null

func play_sound(id:int):
	if id == 0:
		audio_stream_player_3d.max_distance = 0
	else:
		audio_stream_player_3d.max_distance = 10
	audio_stream_player_3d.stream = streams[id]
	audio_stream_player_3d.play()


func _on_navigation_agent_3d_navigation_finished():
	if current_state not in [State.SITTING,State.IDLE]:
		set_random_current_target(3)
	current_state = State.IDLE
