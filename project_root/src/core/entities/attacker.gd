# src/core/entities/attacker.gd
extends GameEntity
class_name Attacker

signal attacker_reached_end(attacker_node) # Nueva señal
signal attacker_died_give_reward(gold_amount) # Nueva señal para recompensa

var movement_speed: float = 50.0 # Píxeles por segundo
var path_points: Array = [] # El camino a seguir
var current_path_index: int = 0
var gold_reward: int = 0

func _init(start_health: float, speed: float, reward: int):
	super._init(start_health)
	self.movement_speed = speed
	self.gold_reward = reward

func set_path(new_path: Array):
	self.path_points = new_path
	self.current_path_index = 0
	if not path_points.empty():
		set_position(path_points[0])

func _physics_process(delta: float): # O _process, según la necesidad
	if is_dead or path_points.empty() or current_path_index >= path_points.size():
		return

	var target_point = path_points[current_path_index]
	var direction = (target_point - get_position()).normalized()
	var distance_to_target = get_position().distance_to(target_point)

	if distance_to_target < movement_speed * delta:
		set_position(target_point)
		current_path_index += 1
		if current_path_index >= path_points.size():
			reach_end_of_path()
	else:
		translate(direction * movement_speed * delta)

func reach_end_of_path():
	print(self.name + " reached the end of the path.")
	emit_signal("attacker_reached_end", self) # Emitir señal
	is_dead = true # Marcar como procesado para que sea limpiado
	if not is_queued_for_deletion():
		queue_free() # Auto-eliminarse

func die():
	# Lógica específica de muerte para atacantes (ej: soltar monedas)
	super.die() # Llama a GameEntity.die()
	# Emitir señal con `gold_reward` para que GameManager lo recoja
	if gold_reward > 0:
		emit_signal("attacker_died_give_reward", gold_reward)
	# El print de "dropped gold" se puede quitar si la UI lo refleja.
	# queue_free() ya es llamado por GameEntity.die() o Attacker.reach_end_of_path()
	# Es importante no llamarlo múltiples veces. GameEntity.die() podría no llamar a queue_free()
	# y dejarlo a las subclases o al sistema que maneja la muerte.
	# Por ahora, asumamos que queue_free() se maneja al final de la cadena de die() o por el sistema.
	# Si GameEntity.die() no hace queue_free(), entonces aquí:
	if not is_queued_for_deletion():
		 queue_free()
