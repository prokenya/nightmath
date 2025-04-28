extends "res://scripts/world.gd"

func _ready():
	super._ready()
	Event.can_use_random_event = false
	var data = {
		"spawn_obj_id": -1,
		"obj_position": enemy_point.global_position,
		"obj_rotation": Vector3(0,0,0),
		"obj_scale": Vector3(1, 1, 1),
		"amount": 1,
		"impulse": Vector3(0, 0, 0),
		"pl_id": Event.mpp_index,
		"custom_properties":{"area_3monitoring":false,"current_target":player,
		"current_state":0,"user_control":true}
		}
	Event.emit_signal("spawn_obj",data)

@onready var world_environment: WorldEnvironment = $WorldEnvironment


func _physics_process(delta: float) -> void:
	world_environment.environment.sky.sky_material.set_shader_parameter("star_size", sin(Time.get_ticks_msec() / 1000.0)*0.05 )
