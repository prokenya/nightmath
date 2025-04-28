class_name trigger
extends Area3D

# Сигнал, который будет вызываться при активации триггера
signal triggered(body)
signal exited(body)


# Свойство для однократного срабатывания
@export var oneshot: bool = false
@export var event_id:String = ""

# Флаг для отслеживания, активирован ли триггер
@export var is_triggered: bool = false

func _ready() -> void:
	connect("body_entered",_on_body_entered)
	connect("body_exited",_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if is_triggered and oneshot:
		return # Игнорируем, если уже было срабатывание и oneshot включён

	#is_triggered = true
	if event_id != "":
		Event.set_event(event_id)

	emit_signal("triggered", body)

func _on_body_exited(body:Node):
	if is_triggered and oneshot:
		return
	if body.is_in_group("player"):
		emit_signal("exited",body)
		is_triggered = true
		#print_debug(body)
