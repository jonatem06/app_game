# src/core/game_manager.gd
extends Node
class_name GameManager

signal lives_changed(current_lives)
signal game_over
signal coins_changed(current_coins)
signal defender_purchase_approved(defender_type_string, cost, position_on_grid) # Para que la escena principal instancie

var player_lives: int = 5
const MAX_LIVES: int = 5
var player_coins: int = 600 # Monedas iniciales

# Podríamos tener referencias a otros managers si es necesario
# var wave_manager_node: WaveManager
# var path_generator_node: PathGenerator
# var ui_manager_node: UIManager # Si tuviéramos uno para actualizar UI

func _ready():
	# Inicializar o cargar estado del juego si es necesario
	print("GameManager ready. Lives: " + str(player_lives) + ", Coins: " + str(player_coins))
	emit_signal("lives_changed", player_lives)
	emit_signal("coins_changed", player_coins)

func reset_level_state():
	player_coins = 600 # Las monedas se reinician por nivel según la solicitud
	# Las vidas no se reinician por nivel, persisten o se reinician al inicio del juego.
	# Si el juego es por niveles y las vidas son para todo el juego:
	# player_lives = MAX_LIVES # Descomentar si las vidas se resetean al inicio de un nuevo juego completo.
	# Si es perder un nivel y reintentar, las vidas podrían o no resetearse.
	# La solicitud original dice "si se llega a 0 en las vidas es un nivel que se perdio",
	# no especifica si las vidas se resetean para el siguiente intento del mismo nivel o para un nuevo nivel.
	# Asumiré que las vidas son para el intento actual del nivel.
	# Si se pierde el nivel, para reintentar, las vidas deberían resetearse a MAX_LIVES.
	player_lives = MAX_LIVES # Resetea vidas para un nuevo intento de nivel.
	print("Level state reset. Lives: " + str(player_lives) + ", Coins: " + str(player_coins))
	emit_signal("lives_changed", player_lives)
	emit_signal("coins_changed", player_coins)


func enemy_reached_castle(enemy: Attacker):
	if enemy == null:
		printerr("GameManager: enemy_reached_castle called with null enemy.")
		return

	if player_lives <= 0: # Si ya es game over, no hacer nada más.
		return

	var lives_lost = 1
	# Comprobar si es un Jefe. Necesitamos una forma segura de hacerlo.
	# Usar class_name es mejor que preload si la escena no está disponible aquí.
	# O mejor aún, el enemigo podría tener una propiedad `lives_cost_on_reach`.
	if enemy.get_class() == "DemonBoss": # Asumiendo DemonBoss tiene class_name DemonBoss
		lives_lost = 2
		print("A Demon Boss reached the castle! Lost " + str(lives_lost) + " lives.")
	else:
		print("An enemy reached the castle! Lost " + str(lives_lost) + " life.")

	player_lives -= lives_lost
	if player_lives < 0:
		player_lives = 0

	emit_signal("lives_changed", player_lives)

	if player_lives <= 0:
		handle_game_over()

func handle_game_over():
	print("Game Over! No lives left.")
	emit_signal("game_over")
	# Aquí se podría pausar el juego, mostrar pantalla de game over, etc.
	# get_tree().paused = true # Ejemplo de pausar el juego

func add_coins(amount: int):
	player_coins += amount
	emit_signal("coins_changed", player_coins)
	print(str(amount) + " coins added. Total coins: " + str(player_coins))

func spend_coins(amount: int) -> bool:
	if player_coins >= amount:
		player_coins -= amount
		emit_signal("coins_changed", player_coins)
		print(str(amount) + " coins spent. Remaining coins: " + str(player_coins))
		return true
	else:
		print("Not enough coins to spend " + str(amount) + ". Current coins: " + str(player_coins))
		return false

func get_player_lives() -> int:
	return player_lives

func get_player_coins() -> int:
	return player_coins

# Nueva función para intentar comprar un defensor
# defender_type_string podría ser "Warrior", "Archer", "Mage"
# position_on_grid es donde el jugador quiere colocarlo (esto vendría de la UI)
func attempt_purchase_defender(defender_type_string: String, defender_cost: int, position_on_grid: Vector2):
	if spend_coins(defender_cost):
		print("Purchase approved for " + defender_type_string + " at " + str(position_on_grid))
		emit_signal("defender_purchase_approved", defender_type_string, defender_cost, position_on_grid)
		# La instanciación real y colocación la manejará el que escuche esta señal (ej: la escena del nivel)
		# Esto es porque GameManager no debería conocer las PackedScenes de los defensores directamente,
		# solo la lógica de negocio de la compra.
	else:
		print("Purchase failed for " + defender_type_string + ". Not enough coins.")
		# Se podría emitir otra señal de "purchase_failed" si la UI necesita reaccionar.
