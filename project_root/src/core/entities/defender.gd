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

var cost: int = 100
var target: Attacker = null
var attack_cooldown: float = 0.0

# --- Sistema de Mejoras ---
var current_upgrade_level: int = 1
const MAX_UPGRADE_LEVEL: int = 4 # Nivel 1 (base) + 3 mejoras

var upgrade_costs: Array = [75, 125, 200] # Costo L1->2, L2->3, L3->4

# Aumentos ADITIVOS por cada mejora sobre el valor del nivel anterior
var additive_damage_upgrades: Array = [3, 6, 5] # Mejora1: +3, Mejora2: +6, Mejora3: +5
var additive_range_upgrades: Array = [2, 2, 2]  # Mejora1: +2, Mejora2: +2, Mejora3: +2

func _init(p_start_health: float,
			p_base_damage: float, p_base_range: float, p_base_speed: float,
			p_cost: int):
	super._init(p_start_health)

	self.base_attack_damage = p_base_damage
	self.base_attack_range = p_base_range
	self.base_attack_speed = p_base_speed
	self.cost = p_cost

	apply_upgrade_stats() # Aplicar stats iniciales (Nivel 1)

func apply_upgrade_stats():
	var calculated_damage = base_attack_damage
	var calculated_range = base_attack_range

	if current_upgrade_level > 1: # Si hay al menos una mejora
		for i in range(current_upgrade_level - 1):
			if i < additive_damage_upgrades.size():
				calculated_damage += additive_damage_upgrades[i]
			else:
				printerr(name + ": Missing additive_damage_upgrades definition for upgrade step " + str(i+1))

			if i < additive_range_upgrades.size():
				calculated_range += additive_range_upgrades[i]
			else:
				printerr(name + ": Missing additive_range_upgrades definition for upgrade step " + str(i+1))

	self.attack_damage = calculated_damage
	self.attack_range = calculated_range
	self.attack_speed = base_attack_speed # Velocidad de ataque no cambia con estas mejoras

func can_upgrade() -> bool:
	return current_upgrade_level < MAX_UPGRADE_LEVEL

func get_next_upgrade_cost() -> int:
	if can_upgrade():
		if current_upgrade_level - 1 < upgrade_costs.size():
			 return upgrade_costs[current_upgrade_level - 1]
		else:
			printerr(name + ": Missing upgrade_costs for level " + str(current_upgrade_level + 1))
			return -1
	return -1

func upgrade():
	if not can_upgrade():
		return false

	current_upgrade_level += 1
	apply_upgrade_stats()
	print(name + " upgraded to Level " + str(current_upgrade_level) +
		  ". New Damage: " + str(attack_damage) +
		  ", New Range: " + str(attack_range) +
		  " (Speed: " + str(attack_speed) + ")")
	return true

func _process(delta: float):
	if is_dead: return
	if attack_cooldown > 0: attack_cooldown -= delta
	if target:
		if target.is_dead or get_position().distance_squared_to(target.get_position()) > (attack_range * attack_range):
			target = null
	if not target: find_target()
	if target and attack_cooldown <= 0: attack()

func find_target():
	target = null
	var potential_targets: Array = get_tree().get_nodes_in_group("attackers")
	var valid_targets_in_range: Array = []
	for t in potential_targets:
		if t is Attacker and not t.is_dead:
			if get_position().distance_squared_to(t.get_position()) <= (attack_range * attack_range):
				valid_targets_in_range.append(t)
	if valid_targets_in_range.empty(): return
	match targeting_priority:
		TargetingPriority.NEAREST_TO_SELF: target = find_nearest_to_self(valid_targets_in_range)
		TargetingPriority.NEAREST_TO_END: target = find_nearest_to_end(valid_targets_in_range)
		TargetingPriority.LOWEST_HEALTH: target = find_lowest_health(valid_targets_in_range)
		TargetingPriority.HIGHEST_HEALTH: target = find_highest_health(valid_targets_in_range)
		_: target = find_nearest_to_self(valid_targets_in_range)

func find_nearest_to_self(targets_in_range: Array) -> Attacker:
	var closest_target: Attacker = null; var min_dist_sq: float = INF
	for t in targets_in_range:
		var dist_sq = get_position().distance_squared_to(t.get_position())
		if dist_sq < min_dist_sq: min_dist_sq = dist_sq; closest_target = t
	return closest_target

func find_lowest_health(targets_in_range: Array) -> Attacker:
	var target_with_lowest_hp: Attacker = null; var min_hp = INF
	for t in targets_in_range:
		if t.health < min_hp: min_hp = t.health; target_with_lowest_hp = t
	return target_with_lowest_hp

func find_highest_health(targets_in_range: Array) -> Attacker:
	var target_with_highest_hp: Attacker = null; var max_hp = -INF
	for t in targets_in_range:
		if t.health > max_hp: max_hp = t.health; target_with_highest_hp = t
	return target_with_highest_hp

func find_nearest_to_end(targets_in_range: Array) -> Attacker:
	var target_most_advanced: Attacker = null; var max_progress: float = -1.0
	var fallback_to_nearest = true
	for t in targets_in_range:
		if t.has_method("get_path_progress"): # Check if attacker can report progress
			fallback_to_nearest = false # At least one target can report progress
			var progress = t.get_path_progress()
			if progress > max_progress: max_progress = progress; target_most_advanced = t
	# If no target could report progress (e.g. all were of a type that doesn't implement get_path_progress)
	# and the list of targets in range was not empty, then fallback to nearest.
	if fallback_to_nearest and not targets_in_range.empty(): return find_nearest_to_self(targets_in_range)
	return target_most_advanced

func attack():
	if not target or target.is_dead: return
	target.take_damage(attack_damage)
	if attack_speed > 0: attack_cooldown = 1.0 / attack_speed
	else: attack_cooldown = INF # Should not happen if base_attack_speed is > 0

func die():
	super.die()
	print(self.name + " defender has been destroyed.")
