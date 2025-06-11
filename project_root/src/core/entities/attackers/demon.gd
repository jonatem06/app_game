# src/core/entities/attackers/demon.gd
extends Attacker
class_name Demon

# La vida inicial y recompensa se pasan al constructor de Attacker
func _init(start_health: float = 40.0, speed: float = 40.0, reward: int = 75):
	super._init(start_health, speed, reward)
	self.name = "Demon"
	# Aquí se podrían añadir propiedades específicas del Demonio si las tuviera
