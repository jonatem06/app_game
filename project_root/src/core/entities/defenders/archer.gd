# src/core/entities/defenders/archer.gd
extends Defender
class_name Archer

func _init():
	# Parámetros para super._init:
	# p_start_health, p_base_damage, p_base_range, p_base_speed, p_cost
	super._init(100.0, 10.0, 150.0, 1.0, 150) # Salud, Daño Base, Rango Base, Vel Ataque Base, Costo Inicial
	self.name = "Archer"

	# Personalización de mejoras para el Arquero (opcional):
	# Los costos de mejora ya están personalizados en la versión anterior, los mantendremos.
	# Si se quieren mantener los costos [100, 200] para L1->2 y L2->3, y añadir para L3->4:
	self.upgrade_costs = [100, 200, 300] # Ejemplo: L1->2 (100), L2->3 (200), L3->4 (300)

	# Si tuviera aumentos de daño aditivos diferentes al genérico de Defender.gd:
	# self.additive_damage_upgrades = [2, 5, 4] # Ej: Daño: +2 (L2), +5 (L3), +4 (L4)
	# Si tuviera aumentos de rango aditivos diferentes al genérico de Defender.gd:
	# self.additive_range_upgrades = [10, 15, 20] # Ej: Rango: +10 (L2), +15 (L3), +20 (L4)

	# Los _factors multiplicativos y la llamada a apply_upgrade_stats() se eliminan.
	# La llamada a apply_upgrade_stats() en Defender._init es suficiente
	# para los stats de Nivel 1. Las personalizaciones de los arrays de mejora
	# aquí se usarán cuando se llame a `upgrade()` en la instancia.
