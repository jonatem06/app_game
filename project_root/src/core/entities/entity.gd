# src/core/entities/entity.gd
extends Node2D # O Sprite, KinematicBody2D según cómo se maneje en Godot
class_name GameEntity

var health: float = 100.0
var max_health: float = 100.0
var is_dead: bool = false

func _init(start_health: float = 100.0):
	self.max_health = start_health
	self.health = start_health

func take_damage(amount: float):
	health -= amount
	if health <= 0:
		health = 0
		is_dead = true
		die() # Método a ser implementado por subclases

func die():
	# Lógica común de muerte, como emitir una señal o prepararse para ser eliminado
	print(self.name + " has died.")
	# NO llamar queue_free() aquí. Dejar que las subclases o el sistema lo manejen
	# después de procesar eventos de muerte como recompensas, etc.
	# Ejemplo: Attacker.die() llamará a queue_free() después de emitir la señal de recompensa.
	pass

func set_position(new_pos: Vector2):
	self.position = new_pos

func get_position() -> Vector2:
	return self.position
