# src/core/entities/defenders/warrior.gd
extends Defender
class_name Warrior

func _init():
	# Stats: Ataque 15, Rango 5 (pixeles), Vida (ej: 150), Velocidad Ataque (ej: 1.2), Costo 100
	# El rango es muy pequeño, se ajustará al tamaño de los sprites.
	# Por ahora, usaré valores un poco más grandes para rango para que sea funcional.
	super._init(150.0, 15.0, 50.0, 1.2, 100)
	self.name = "Warrior"
