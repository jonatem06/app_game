# src/core/entities/defenders/mage.gd
extends Defender
class_name Mage

enum Element { FIRE, ICE, EARTH, AIR }
var elemental_type: int = Element.FIRE # Por defecto
var status_chance: float = 0.10 # 10%

func _init(element: int = Element.FIRE):
	# Stats: Ataque 8, Rango 15 (pixeles), Vida (ej: 80), Velocidad Ataque (ej: 0.8), Costo 200
	super._init(80.0, 8.0, 200.0, 0.8, 200)
	self.name = "Mage"
	self.elemental_type = element
	# El nombre podría reflejar el elemento, ej: "FireMage"
	# self.name = str(Element.keys()[element]) + "Mage" # Godot 4
	match element:
		Element.FIRE: self.name = "FireMage"
		Element.ICE: self.name = "IceMage"
		Element.EARTH: self.name = "EarthMage"
		Element.AIR: self.name = "AirMage"


func attack():
	super.attack() # Llama al método de ataque base para hacer daño

	if target and not target.is_dead: # Asegurarse de que el objetivo aún existe
		if randf() < status_chance: # randf() devuelve float entre 0 y 1
			apply_elemental_status()

func apply_elemental_status():
	if not target: return

	match elemental_type:
		Element.FIRE:
			# Lógica para quemar (ej: daño por tiempo)
			print(target.name + " is burned by " + self.name)
			# target.apply_status("burn", duration, dps)
		Element.ICE:
			# Lógica para congelar (ej: reducir velocidad de movimiento)
			print(target.name + " is frozen by " + self.name)
			# target.apply_status("freeze", duration, slow_factor)
		Element.EARTH, Element.AIR:
			# Lógica para retroceder
			print(target.name + " is pushed back by " + self.name)
			# target.push_back(distance)
	# La implementación de los estados alterados (DoT, slow, pushback)
	# requerirá añadir lógica en la clase Attacker o GameEntity.
	# Por ahora, solo se imprime el efecto.
