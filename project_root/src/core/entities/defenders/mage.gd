# src/core/entities/defenders/mage.gd
extends Defender
class_name Mage

enum Element { FIRE, ICE, EARTH, AIR } # EARTH y AIR harán pushback
var elemental_type: int = Element.FIRE
var status_chance: float = 0.10

# Parámetros de los efectos
const BURN_DPS = 5.0
const BURN_DURATION = 3.0
const SLOW_FACTOR = 0.5 # Reduce la velocidad a la mitad
const SLOW_DURATION = 2.0
const PUSHBACK_DISTANCE = 50.0 # Píxeles

func _init(element: int = Element.FIRE):
	super._init(80.0, 8.0, 200.0, 0.8, 200) # Vida, Ataque, Rango, Vel Ataque, Costo
	self.elemental_type = element
	match element:
		Element.FIRE: self.name = "FireMage"
		Element.ICE: self.name = "IceMage"
		Element.EARTH: self.name = "EarthMage"
		Element.AIR: self.name = "AirMage"
		_: self.name = "Mage"

func attack():
	super.attack()

	if target and not target.is_dead: # target es una variable de la clase Defender (Attacker)
		if randf() < status_chance:
			apply_elemental_status(target) # Pasar el objetivo (que es un Attacker)

func apply_elemental_status(current_target: Attacker): # Recibir el objetivo
	# Asegurarse de que current_target es un Attacker válido antes de llamar a sus métodos.
	# La variable `target` ya es de tipo Attacker (o debería serlo).
	if not current_target is Attacker:
		printerr(self.name + " tried to apply status to a non-Attacker target: " + str(current_target))
		return

	# Adicionalmente, comprobar si el target tiene los métodos esperados podría ser útil
	# pero dado que son Attacker, deberían tenerlos si el script Attacker.gd está bien.
	# Ejemplo de comprobación más robusta (opcional):
	# if not current_target.has_method("apply_burn") or \
	#    not current_target.has_method("apply_slow") or \
	#    not current_target.has_method("apply_pushback"):
	#     printerr(self.name + " target " + current_target.name + " does not support all status effect methods.")
	#     return

	match elemental_type:
		Element.FIRE:
			print(self.name + " applies FIRE effect to " + current_target.name)
			current_target.apply_burn(BURN_DPS, BURN_DURATION)
		Element.ICE:
			print(self.name + " applies ICE effect to " + current_target.name)
			current_target.apply_slow(SLOW_FACTOR, SLOW_DURATION)
		Element.EARTH: # Tierra y Aire hacen retroceder
			print(self.name + " applies EARTH (Pushback) effect to " + current_target.name)
			current_target.apply_pushback(PUSHBACK_DISTANCE)
		Element.AIR:
			print(self.name + " applies AIR (Pushback) effect to " + current_target.name)
			current_target.apply_pushback(PUSHBACK_DISTANCE)
