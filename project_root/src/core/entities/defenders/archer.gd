# src/core/entities/defenders/archer.gd
extends Defender
class_name Archer

func _init():
	# Parámetros para super._init:
	# p_start_health, p_base_damage, p_base_range, p_base_speed, p_cost
	super._init(100.0, 10.0, 150.0, 5.0, 150) # p_base_speed cambiado a 5.0
	self.name = "Archer"

	self.upgrade_costs = [100, 200, 300]
	# self.additive_damage_upgrades = [3, 6, 5] # Usará el de Defender.gd
	# self.additive_range_upgrades = [2, 2, 2]  # Usará el de Defender.gd
	self.additive_speed_upgrades = [3, 3, 3] # Mejora1: +3, Mejora2: +3, Mejora3: +3
