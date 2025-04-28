extends Area3D



func _on_body_entered(body: PhysicsBody3D) -> void:
	if body.is_in_group("player"):
		if Event.userdata.fun_mode:
			Event.world.switch_scene(false,"res://scen/levels/world3.tscn",false)
		else:
			Event.world.switch_scene(false,"res://scen/levels/final.tscn",false)
	else:
		body.linear_velocity = Vector3.ZERO
		body.global_position = Vector3(1,1,-2)
