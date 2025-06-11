# src/core/entities/defenders/archer.gd
extends Defender
class_name Archer

func _init():
	# Stats: Ataque 10, Rango 10 (pixeles), Vida (ej: 100), Velocidad Ataque (ej: 1.0), Costo 150
	super._init(100.0, 10.0, 150.0, 1.0, 150)
	self.name = "Archer"
