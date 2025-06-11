# src/core/entities/attackers/demon.gd
extends Attacker
class_name Demon

# El constructor ahora toma la vida inicial.
# La velocidad y recompensa pueden tener valores por defecto si no se proporcionan.
func _init(health: float = 40.0, speed: float = 40.0, reward: int = 75):
	super._init(health, speed, reward) # Pasa la vida al constructor de Attacker
	self.name = "Demon"
