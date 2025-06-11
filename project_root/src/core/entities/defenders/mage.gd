# src/core/entities/defenders/mage.gd
extends Defender
class_name Mage

enum Element { FIRE, ICE, EARTH, AIR }
var elemental_type: int = Element.FIRE
var status_chance: float = 0.10 # Este podría ser mejorable también

# Parámetros de los efectos base (podrían escalar con mejoras también)
const BURN_DPS = 5.0
const BURN_DURATION = 3.0
const SLOW_FACTOR = 0.5
const SLOW_DURATION = 2.0
const PUSHBACK_DISTANCE = 50.0

func _init(element: int = Element.FIRE): # Permitir especificar elemento al crear
	# Parámetros para super._init:
	# p_start_health, p_base_damage, p_base_range, p_base_speed, p_cost
	super._init(80.0, 8.0, 200.0, 0.8, 200) # Salud, Daño Base, Rango Base, Vel Ataque Base, Costo Inicial

	self.elemental_type = element
	match element:
		Element.FIRE: self.name = "FireMage"
		Element.ICE: self.name = "IceMage"
		Element.EARTH: self.name = "EarthMage"
		Element.AIR: self.name = "AirMage"
		_: self.name = "Mage"

	# Personalización de mejoras para el Mago:
	self.upgrade_costs = [125, 250] # Lvl1->2: 125, Lvl2->3: 250
	self.upgrade_damage_factors = [1.0, 1.5, 2.1]  # Daño: +50% L2, +110% L3
	self.upgrade_range_factors =  [1.0, 1.15, 1.3] # Rango: +15% L2, +30% L3
	self.upgrade_speed_factors =  [1.0, 1.1, 1.2]  # Vel Ataque: +10% L2, +20% L3
	# Podríamos añadir: self.upgrade_status_chance_factors = [1.0, 1.5, 2.0] y aplicarlo en apply_upgrade_stats

	# Re-aplicar stats con los factores específicos del Mago para Nivel 1.
	apply_upgrade_stats()

func attack():
	super.attack()

	if target and not target.is_dead:
		if randf() < status_chance: # status_chance podría ser mejorado
			apply_elemental_status(target)

func apply_elemental_status(current_target: Attacker):
	if not current_target is Attacker:
		printerr(self.name + " tried to apply status to a non-Attacker target: " + str(current_target))
		return

	# Los parámetros de efecto (BURN_DPS, etc.) podrían escalar con el nivel del mago también.
	# Por ahora, son constantes.
	match elemental_type:
		Element.FIRE:
			# print(self.name + " applies FIRE effect to " + current_target.name)
			current_target.apply_burn(BURN_DPS, BURN_DURATION)
		Element.ICE:
			# print(self.name + " applies ICE effect to " + current_target.name)
			current_target.apply_slow(SLOW_FACTOR, SLOW_DURATION)
		Element.EARTH:
			# print(self.name + " applies EARTH (Pushback) effect to " + current_target.name)
			current_target.apply_pushback(PUSHBACK_DISTANCE)
		Element.AIR:
			# print(self.name + " applies AIR (Pushback) effect to " + current_target.name)
			current_target.apply_pushback(PUSHBACK_DISTANCE)
