# src/core/game_manager.gd
extends Node
class_name GameManager

signal lives_changed(current_lives)
signal game_over
signal coins_changed(current_coins)
signal defender_purchase_approved(defender_type_string, cost, position_on_grid)
signal defender_upgraded(defender_node, new_level)
signal towers_unlocked_changed(unlocked_towers_array) # Nueva señal

var player_lives: int = 5
const MAX_LIVES: int = 5
var player_coins: int = 600

# --- Sistema de Desbloqueo de Torres ---
# Los tipos de torres se identificarán por sus strings ("Warrior", "Archer", "Mage")
var unlocked_towers: Array = ["Warrior"] # Guerrero desbloqueado por defecto
# Podríamos tener una lista de todas las torres posibles para referencia
const ALL_TOWER_TYPES: Array = ["Warrior", "Archer", "Mage"]


func _ready():
	print("GameManager ready. Lives: " + str(player_lives) + ", Coins: " + str(player_coins))
	emit_signal("lives_changed", player_lives)
	emit_signal("coins_changed", player_coins)
	# Emitir estado inicial de torres desbloqueadas para que la UI se actualice
	emit_signal("towers_unlocked_changed", unlocked_towers)

func reset_level_state():
	player_coins = 600
	player_lives = MAX_LIVES
	print("Level state reset. Lives: " + str(player_lives) + ", Coins: " + str(player_coins))
	emit_signal("lives_changed", player_lives)
	emit_signal("coins_changed", player_coins)
	# Los desbloqueos de torres son persistentes, no se resetean por nivel.
	# Se resetean al iniciar un juego completamente nuevo (que no manejamos aún).

func enemy_reached_castle(enemy: Attacker):
	if enemy == null:
		printerr("GameManager: enemy_reached_castle called with null enemy.")
		return
	if player_lives <= 0:
		return
	var lives_lost = 1
	if enemy.get_class() == "DemonBoss":
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

func add_coins(amount: int):
	player_coins += amount
	emit_signal("coins_changed", player_coins)
	# print(str(amount) + " coins added. Total coins: " + str(player_coins)) # Un poco verboso para cada moneda

func spend_coins(amount: int) -> bool:
	if player_coins >= amount:
		player_coins -= amount
		emit_signal("coins_changed", player_coins)
		# print(str(amount) + " coins spent. Remaining coins: " + str(player_coins)) # Verboso
		return true
	else:
		# print("Not enough coins to spend " + str(amount) + ". Current coins: " + str(player_coins)) # Verboso
		return false

func get_player_lives() -> int:
	return player_lives

func get_player_coins() -> int:
	return player_coins

func attempt_purchase_defender(defender_type_string: String, defender_cost: int, position_on_grid: Vector2):
	if spend_coins(defender_cost):
		# print("Purchase approved for " + defender_type_string + " at " + str(position_on_grid)) # Movido a UI/MainGame
		emit_signal("defender_purchase_approved", defender_type_string, defender_cost, position_on_grid)
	else:
		print("Purchase failed for " + defender_type_string + ". Not enough coins.")

func attempt_upgrade_defender(defender_instance: Defender):
	if not defender_instance or not is_instance_valid(defender_instance):
		printerr("GameManager: Attempted to upgrade an invalid defender instance.")
		return
	if not defender_instance.can_upgrade():
		# print("GameManager: " + defender_instance.name + " cannot be upgraded further.") # UI podría manejar esto
		return
	var upgrade_cost = defender_instance.get_next_upgrade_cost()
	if upgrade_cost == -1:
		printerr("GameManager: Could not get upgrade cost for " + defender_instance.name)
		return
	if player_coins >= upgrade_cost:
		if spend_coins(upgrade_cost):
			if defender_instance.upgrade():
				print("GameManager: " + defender_instance.name + " successfully upgraded to level " + str(defender_instance.current_upgrade_level))
				emit_signal("defender_upgraded", defender_instance, defender_instance.current_upgrade_level)
			else:
				add_coins(upgrade_cost)
				printerr("GameManager: Upgrade failed for " + defender_instance.name + " after spending coins. Refunding.")
	# else: # UI podría manejar "not enough coins"
		# print("GameManager: Not enough coins to upgrade " + defender_instance.name)

# --- Funciones de Desbloqueo de Torres ---
func unlock_tower(tower_type_string: String):
	if not tower_type_string in ALL_TOWER_TYPES:
		printerr("GameManager: Attempted to unlock an unknown tower type: " + tower_type_string)
		return

	if not tower_type_string in unlocked_towers:
		unlocked_towers.append(tower_type_string)
		print("GameManager: Tower type '" + tower_type_string + "' has been unlocked!")
		emit_signal("towers_unlocked_changed", unlocked_towers)
	else:
		print("GameManager: Tower type '" + tower_type_string + "' was already unlocked.")

func is_tower_unlocked(tower_type_string: String) -> bool:
	return tower_type_string in unlocked_towers

func get_unlocked_towers() -> Array:
	return unlocked_towers.duplicate()

func reset_all_progress_for_new_game():
	reset_level_state()
	unlocked_towers = ["Warrior"]
	emit_signal("towers_unlocked_changed", unlocked_towers)
	print("GameManager: All game progress reset. Starting fresh.")
