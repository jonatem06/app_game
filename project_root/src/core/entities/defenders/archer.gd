# src/core/entities/defenders/archer.gd
extends Defender
class_name Archer

func _init():
	# Parámetros para super._init:
	# p_start_health, p_base_damage, p_base_range, p_base_speed, p_cost
	super._init(100.0, 10.0, 150.0, 1.0, 150) # Salud, Daño Base, Rango Base, Vel Ataque Base, Costo Inicial
	self.name = "Archer"

	# Personalización de mejoras para el Arquero:
	self.upgrade_costs = [100, 200] # Lvl1->2: 100, Lvl2->3: 200
	self.upgrade_damage_factors = [1.0, 1.4, 1.9]  # Daño: +40% L2, +90% L3
	self.upgrade_range_factors =  [1.0, 1.25, 1.5] # Rango: +25% L2, +50% L3
	self.upgrade_speed_factors =  [1.0, 1.15, 1.3] # Vel Ataque: +15% L2, +30% L3

	# Re-aplicar stats con los factores específicos del Archer para Nivel 1.
	apply_upgrade_stats()
