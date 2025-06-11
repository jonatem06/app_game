# src/core/entities/defender.gd
extends GameEntity
class_name Defender

enum TargetingPriority { NEAREST_TO_SELF, NEAREST_TO_END, LOWEST_HEALTH, HIGHEST_HEALTH }
export var targeting_priority: int = TargetingPriority.NEAREST_TO_SELF

# Stats base (serán los del Nivel 1)
var base_attack_damage: float = 10.0
var base_attack_range: float = 100.0
var base_attack_speed: float = 1.0
# Stats actuales (modificados por mejoras)
var attack_damage: float
var attack_range: float
var attack_speed: float

var cost: int = 100 # Costo de compra inicial
var target: Attacker = null
var attack_cooldown: float = 0.0

# --- Sistema de Mejoras ---
var current_upgrade_level: int = 1
const MAX_UPGRADE_LEVEL: int = 3 # Ej: Nivel 1 (base), Nivel 2, Nivel 3

# Costos para mejorar A PARTIR del nivel actual.
# upgrade_costs[0] es costo para pasar de Nivel 1 a Nivel 2
# upgrade_costs[1] es costo para pasar de Nivel 2 a Nivel 3
var upgrade_costs: Array = [50, 100] # Ejemplo: Lvl1->2 cuesta 50, Lvl2->3 cuesta 100

# Factores de mejora por nivel (multiplicativo sobre el base)
# upgrade_damage_factors[0] es para Nivel 1 (sin cambio), [1] para Nivel 2, etc.
# Estos son multiplicadores totales, no incrementales.
var upgrade_damage_factors: Array = [1.0, 1.5, 2.0] # Nivel 1: 100%, Nivel 2: 150%, Nivel 3: 200% del daño base
var upgrade_range_factors: Array = [1.0, 1.2, 1.4]  # Nivel 1: 100%, Nivel 2: 120%, Nivel 3: 140% del rango base
# La velocidad de ataque podría disminuir el cooldown (más rápido) o aumentar ataques por segundo.
# Si es ataques por segundo, también se multiplica.
var upgrade_speed_factors: Array = [1.0, 1.1, 1.25]


func _init(p_start_health: float,
			p_base_damage: float, p_base_range: float, p_base_speed: float,
			p_cost: int):
	super._init(p_start_health)

	self.base_attack_damage = p_base_damage
	self.base_attack_range = p_base_range
	self.base_attack_speed = p_base_speed
	self.cost = p_cost

	# Aplicar stats iniciales (Nivel 1)
	apply_upgrade_stats()


func _process(delta: float):
	if is_dead:
		return

	if attack_cooldown > 0:
		attack_cooldown -= delta

	if target:
		if target.is_dead or get_position().distance_squared_to(target.get_position()) > (attack_range * attack_range):
			target = null

	if not target:
		find_target()

	if target and attack_cooldown <= 0:
		attack()

func find_target():
	target = null
	var potential_targets: Array = get_tree().get_nodes_in_group("attackers")
	var valid_targets_in_range: Array = []

	for t in potential_targets:
		if t is Attacker and not t.is_dead:
			if get_position().distance_squared_to(t.get_position()) <= (attack_range * attack_range):
				valid_targets_in_range.append(t)

	if valid_targets_in_range.empty():
		return

	match targeting_priority:
		TargetingPriority.NEAREST_TO_SELF:
			target = find_nearest_to_self(valid_targets_in_range)
		TargetingPriority.NEAREST_TO_END:
			target = find_nearest_to_end(valid_targets_in_range)
		TargetingPriority.LOWEST_HEALTH:
			target = find_lowest_health(valid_targets_in_range)
		TargetingPriority.HIGHEST_HEALTH:
			target = find_highest_health(valid_targets_in_range)
		_:
			target = find_nearest_to_self(valid_targets_in_range)

func find_nearest_to_self(targets_in_range: Array) -> Attacker:
	var closest_target: Attacker = null
	var min_dist_sq: float = INF
	for t in targets_in_range:
		var dist_sq = get_position().distance_squared_to(t.get_position())
		if dist_sq < min_dist_sq:
			min_dist_sq = dist_sq
			closest_target = t
	return closest_target

func find_lowest_health(targets_in_range: Array) -> Attacker:
	var target_with_lowest_hp: Attacker = null
	var min_hp = INF
	for t in targets_in_range:
		if t.health < min_hp:
			min_hp = t.health
			target_with_lowest_hp = t
	return target_with_lowest_hp

func find_highest_health(targets_in_range: Array) -> Attacker:
	var target_with_highest_hp: Attacker = null
	var max_hp = -INF
	for t in targets_in_range:
		if t.health > max_hp:
			max_hp = t.health
			target_with_highest_hp = t
	return target_with_highest_hp

func find_nearest_to_end(targets_in_range: Array) -> Attacker:
	var target_most_advanced: Attacker = null
	var max_progress: float = -1.0
	var all_targets_lack_method = true
	for t in targets_in_range:
		if not t.has_method("get_path_progress"):
			printerr("Defender: Target " + t.name + " does not have get_path_progress(). Cannot use NEAREST_TO_END for this target.")
			continue
		all_targets_lack_method = false
		var progress = t.get_path_progress()
		if progress > max_progress:
			max_progress = progress
			target_most_advanced = t
	if all_targets_lack_method and not targets_in_range.empty():
		return find_nearest_to_self(targets_in_range)
	return target_most_advanced

func attack():
	if not target or target.is_dead:
		return
	target.take_damage(attack_damage)
	attack_cooldown = 1.0 / attack_speed

func die():
	super.die()
	print(self.name + " defender has been destroyed.")

# --- Funciones de Mejora ---
func can_upgrade() -> bool:
	return current_upgrade_level < MAX_UPGRADE_LEVEL

func get_next_upgrade_cost() -> int:
	if can_upgrade():
		if current_upgrade_level -1 < upgrade_costs.size():
			 return upgrade_costs[current_upgrade_level - 1]
		else:
			printerr(name + ": Missing upgrade_costs for level " + str(current_upgrade_level + 1))
			return -1
	return -1

func upgrade():
	if not can_upgrade():
		print(name + " is already at max level (" + str(MAX_UPGRADE_LEVEL) + ").")
		return false

	var cost_for_this_upgrade = get_next_upgrade_cost()
	if cost_for_this_upgrade == -1:
		 print(name + ": Cannot upgrade, cost not defined for next level.")
		 return false

	current_upgrade_level += 1
	apply_upgrade_stats()
	print(name + " upgraded to Level " + str(current_upgrade_level) +
		  ". Damage: " + str(attack_damage) + ", Range: " + str(attack_range) + ", Speed: " + str(attack_speed))
	return true

func apply_upgrade_stats():
	var level_idx = current_upgrade_level - 1

	if level_idx < upgrade_damage_factors.size():
		attack_damage = base_attack_damage * upgrade_damage_factors[level_idx]
	else: attack_damage = base_attack_damage * upgrade_damage_factors[upgrade_damage_factors.size()-1]

	if level_idx < upgrade_range_factors.size():
		attack_range = base_attack_range * upgrade_range_factors[level_idx]
	else: attack_range = base_attack_range * upgrade_range_factors[upgrade_range_factors.size()-1]

	if level_idx < upgrade_speed_factors.size():
		attack_speed = base_attack_speed * upgrade_speed_factors[level_idx]
	else: attack_speed = base_attack_speed * upgrade_speed_factors[upgrade_speed_factors.size()-1]
