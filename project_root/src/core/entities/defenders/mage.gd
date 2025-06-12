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
	super._init(80.0, 8.0, 200.0, 7.0, 200) # p_base_speed cambiado a 7.0

	self.elemental_type = element
	match element:
		Element.FIRE: self.name = "FireMage"
		Element.ICE: self.name = "IceMage"
		Element.EARTH: self.name = "EarthMage"
		Element.AIR: self.name = "AirMage"
		_: self.name = "Mage"

	# Personalización de mejoras para el Mago (opcional):
	# Los costos de mejora ya están personalizados en la versión anterior, los adaptaremos.
	self.upgrade_costs = [125, 250, 375]
	# self.additive_damage_upgrades = [3, 6, 5] # Usará el de Defender.gd
	# self.additive_range_upgrades = [2, 2, 2]  # Usará el de Defender.gd
	self.additive_speed_upgrades = [3, 3, 3] # Mejora1: +3, Mejora2: +3, Mejora3: +3

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
			current_target.apply_burn(BURN_DPS, BURN_DURATION)
		Element.ICE:
			current_target.apply_slow(SLOW_FACTOR, SLOW_DURATION)
		Element.EARTH:
			current_target.apply_pushback(PUSHBACK_DISTANCE)
		Element.AIR:
			current_target.apply_pushback(PUSHBACK_DISTANCE)
