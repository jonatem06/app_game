# src/core/entities/defenders/warrior.gd
extends Defender
class_name Warrior

func _init():
	# Parámetros para super._init:
	# p_start_health, p_base_damage, p_base_range, p_base_speed, p_cost
	super._init(150.0, 15.0, 50.0, 1.2, 100)
	self.name = "Warrior"

	# Personalización de mejoras para el Guerrero (opcional):
	# Si el Guerrero tuviera costos de mejora diferentes a los de Defender.gd:
	# self.upgrade_costs = [80, 130, 210]
	# Si tuviera aumentos de daño aditivos diferentes:
	# self.additive_damage_upgrades = [4, 7, 6] # Ej: +4, +7, +6 para L2, L3, L4

	# Los _factors multiplicativos ya no se usan.
	# La llamada a apply_upgrade_stats() en Defender._init es suficiente
	# para establecer los stats iniciales (Nivel 1), ya que el bucle de daño aditivo
	# en apply_upgrade_stats (de Defender.gd) no se ejecutará para current_upgrade_level = 1,
	# y rango/velocidad se establecen a sus valores base.
	# No es necesario llamar a apply_upgrade_stats() aquí de nuevo.
