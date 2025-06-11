# src/core/entities/defenders/warrior.gd
extends Defender
class_name Warrior

func _init():
	# Parámetros para super._init:
	# p_start_health, p_base_damage, p_base_range, p_base_speed, p_cost
	super._init(150.0, 15.0, 50.0, 1.2, 100)
	self.name = "Warrior"

	# Ejemplo de personalización de mejoras para el Guerrero:
	self.upgrade_costs = [75, 150] # Costo Lvl1->2: 75, Lvl2->3: 150
	self.upgrade_damage_factors = [1.0, 1.6, 2.2] # Daño: +60% en L2, +120% en L3
	self.upgrade_range_factors =  [1.0, 1.1, 1.2]  # Rango: +10% en L2, +20% en L3
	self.upgrade_speed_factors =  [1.0, 1.0, 1.1]  # Velocidad: sin cambio en L2, +10% en L3

	# Re-aplicar stats con los factores específicos del Warrior para Nivel 1.
	# Esto es necesario si los factores de Nivel 1 aquí son diferentes de 1.0,
	# o si los arrays de factores base en Defender.gd no tuvieran el tamaño adecuado
	# y se quisiera asegurar que esta subclase usa sus propios arrays completos.
	# Dado que Defender._init llama a apply_upgrade_stats(), y los factores de nivel 1
	# son típicamente 1.0, esto podría ser redundante si los factores de nivel 1
	# de esta clase también son 1.0. Sin embargo, para robustez y claridad si
	# los factores de nivel 1 se personalizan para no ser 1.0, llamarlo de nuevo es más seguro.
	apply_upgrade_stats()
