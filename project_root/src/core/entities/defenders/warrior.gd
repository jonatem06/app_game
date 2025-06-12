# src/core/entities/defenders/warrior.gd
extends Defender
class_name Warrior

func _init():
	# Parámetros para super._init:
	# p_start_health, p_base_damage, p_base_range, p_base_speed, p_cost
	super._init(150.0, 15.0, 50.0, 3.0, 100) # p_base_speed cambiado a 3.0
	self.name = "Warrior"

	# Valores específicos de mejora para el Guerrero
	# self.upgrade_costs = [75, 125, 200] # Usará el de Defender.gd si no se especifica
	# self.additive_damage_upgrades = [3, 6, 5] # Usará el de Defender.gd
	# self.additive_range_upgrades = [2, 2, 2]  # Usará el de Defender.gd
	self.additive_speed_upgrades = [4, 4, 4] # Mejora1: +4, Mejora2: +4, Mejora3: +4
