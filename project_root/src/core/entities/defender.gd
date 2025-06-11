# src/core/entities/defender.gd
extends GameEntity
class_name Defender

var attack_damage: float = 10.0
var attack_range: float = 100.0 # Radio en píxeles
var attack_speed: float = 1.0  # Ataques por segundo
var cost: int = 100
var target: Attacker = null
var attack_cooldown: float = 0.0

func _init(start_health: float, damage: float, range: float, speed: float, cost_val: int):
	super._init(start_health)
	self.attack_damage = damage
	self.attack_range = range
	self.attack_speed = speed
	self.cost = cost_val

func _process(delta: float):
	if is_dead:
		return

	if attack_cooldown > 0:
		attack_cooldown -= delta

	if target and (target.is_dead or get_position().distance_to(target.get_position()) > attack_range):
		target = null # Perdió el objetivo o está fuera de rango

	if not target:
		find_target() # Buscar un nuevo objetivo

	if target and attack_cooldown <= 0:
		attack()

func find_target():
	target = null # Resetear objetivo anterior
	var potential_targets = get_tree().get_nodes_in_group("attackers") # Asume que los atacantes están en este grupo
	var closest_target: Attacker = null
	var min_dist_sq: float = (attack_range * attack_range) + 1.0 # Comparar distancias cuadradas para eficiencia

	for t in potential_targets:
		if t is Attacker and not t.is_dead: # Asegurarse que es un Attacker y está vivo
			var distance_sq_to_t = get_position().distance_squared_to(t.get_position())
			if distance_sq_to_t < min_dist_sq:
				min_dist_sq = distance_sq_to_t
				closest_target = t

	if closest_target != null and min_dist_sq <= (attack_range * attack_range) : # Doble check por si el más cercano aún está fuera de rango
		self.target = closest_target
	else:
		self.target = null # Ningún objetivo encontrado en rango

func attack():
	if not target or target.is_dead:
		return

	print(self.name + " attacks " + target.name + " for " + str(attack_damage) + " damage.")
	target.take_damage(attack_damage)
	attack_cooldown = 1.0 / attack_speed # Resetear cooldown

func die():
	super.die()
	# Lógica específica de muerte para defensores
	print(self.name + " defender has been destroyed.")
	# queue_free()
