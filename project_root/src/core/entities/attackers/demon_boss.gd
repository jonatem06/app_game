# src/core/entities/attackers/demon_boss.gd
extends Attacker
class_name DemonBoss

# Los jefes son más fuertes y dan mejor recompensa
func _init(start_health: float = 200.0, speed: float = 30.0, reward: int = 100):
	super._init(start_health, speed, reward)
	self.name = "DemonBoss"
	# Propiedades específicas del Jefe Demonio
