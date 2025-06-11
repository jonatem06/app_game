# src/core/game_manager.gd
extends Node
class_name GameManager

signal lives_changed(current_lives)
signal game_over
signal coins_changed(current_coins)
signal defender_purchase_approved(defender_type_string, cost, position_on_grid)
signal defender_upgraded(defender_node, new_level)
signal towers_unlocked_changed(unlocked_towers_array)
signal difficulty_changed(new_difficulty_enum, general_difficulty_multiplier) # Señal con multiplicador general

var player_lives: int = 5
const MAX_LIVES: int = 5
var player_coins_base: int = 600
var player_coins: int = 600

var unlocked_towers: Array = ["Warrior"]
const ALL_TOWER_TYPES: Array = ["Warrior", "Archer", "Mage"]

# --- Sistema de Dificultad ---
enum Difficulty { NORMAL, DIFFICULT, HARD }
var current_difficulty_setting: int = Difficulty.NORMAL
var difficulty_multiplier: float = 1.0 # Multiplicador general


func _ready():
	set_difficulty(Difficulty.NORMAL)
	# player_coins se establece a través de set_difficulty -> _update_player_coins -> emit(coins_changed)
	# Vidas iniciales
	emit_signal("lives_changed", player_lives)
	# Torres iniciales
	emit_signal("towers_unlocked_changed", unlocked_towers)
	print("GameManager ready. Initial Difficulty: " + str(Difficulty.keys()[current_difficulty_setting]) +
		  ", General Multiplier: " + str(difficulty_multiplier) + ", Initial Coins: " + str(player_coins))

func set_difficulty(new_difficulty: int):
	current_difficulty_setting = new_difficulty
	match current_difficulty_setting:
		Difficulty.NORMAL:
			difficulty_multiplier = 1.0
		Difficulty.DIFFICULT:
			difficulty_multiplier = 2.0 # Según solicitud del usuario
		Difficulty.HARD:
			difficulty_multiplier = 4.0 # Según solicitud del usuario
		_:
			difficulty_multiplier = 1.0

	print("GameManager: Difficulty set to " + str(Difficulty.keys()[current_difficulty_setting]) +
		  ", General Multiplier: " + str(difficulty_multiplier))
	_update_player_coins()
	emit_signal("difficulty_changed", current_difficulty_setting, difficulty_multiplier) # Emitir el multiplicador general


func _update_player_coins():
	# Monedas iniciales del jugador son MÁS ALTAS en dificultades más altas (para compensar enemigos más duros)
	# O podrían ser MÁS BAJAS si el multiplicador se interpreta como "costo de las cosas".
	# La solicitud original era: "Este multiplicador se usará tanto para las monedas iniciales del jugador como para la vida de los enemigos."
	# Si un multiplicador de 2.0 significa enemigos con doble vida, también debería significar doble de monedas iniciales.
	player_coins = int(player_coins_base * difficulty_multiplier)
	emit_signal("coins_changed", player_coins) # Emitir siempre para que UI se actualice


func reset_level_state():
	player_lives = MAX_LIVES
	emit_signal("lives_changed", player_lives)
	_update_player_coins()
	print("Level state reset. Lives: " + str(player_lives) +
		  ", Coins: " + str(player_coins) +
		  " (Difficulty: " + str(Difficulty.keys()[current_difficulty_setting]) + ")")

func get_difficulty_multiplier() -> float: # Esta es ahora la única función getter para el multiplicador
	return difficulty_multiplier

func get_current_difficulty_enum() -> int:
	return current_difficulty_setting

# --- El resto de las funciones permanecen igual ---

func enemy_reached_castle(enemy: Attacker):
	if enemy == null: return
	if player_lives <= 0: return
	var lives_lost = 1
	if enemy.get_class() == "DemonBoss": lives_lost = 2
	player_lives -= lives_lost
	if player_lives < 0: player_lives = 0
	emit_signal("lives_changed", player_lives)
	if player_lives <= 0: handle_game_over()

func handle_game_over():
	print("Game Over! No lives left.")
	emit_signal("game_over")

func add_coins(amount: int):
	player_coins += amount
	emit_signal("coins_changed", player_coins)

func spend_coins(amount: int) -> bool:
	if player_coins >= amount:
		player_coins -= amount
		emit_signal("coins_changed", player_coins)
		return true
	return false

func attempt_purchase_defender(defender_type_string: String, defender_cost: int, position_on_grid: Vector2):
	if spend_coins(defender_cost):
		emit_signal("defender_purchase_approved", defender_type_string, defender_cost, position_on_grid)
	else:
		print("Purchase failed for " + defender_type_string + ". Not enough coins.")

func attempt_upgrade_defender(defender_instance: Defender):
	if not defender_instance or not is_instance_valid(defender_instance): return
	if not defender_instance.can_upgrade(): return
	var upgrade_cost = defender_instance.get_next_upgrade_cost()
	if upgrade_cost == -1: return
	if player_coins >= upgrade_cost:
		if spend_coins(upgrade_cost):
			if defender_instance.upgrade():
				emit_signal("defender_upgraded", defender_instance, defender_instance.current_upgrade_level)
			else:
				add_coins(upgrade_cost)

func unlock_tower(tower_type_string: String):
	if not tower_type_string in ALL_TOWER_TYPES: return
	if not tower_type_string in unlocked_towers:
		unlocked_towers.append(tower_type_string)
		emit_signal("towers_unlocked_changed", unlocked_towers)

func is_tower_unlocked(tower_type_string: String) -> bool:
	return tower_type_string in unlocked_towers

func get_unlocked_towers() -> Array:
	return unlocked_towers.duplicate()

func reset_all_progress_for_new_game():
	set_difficulty(Difficulty.NORMAL)
	reset_level_state()
	unlocked_towers = ["Warrior"]
	emit_signal("towers_unlocked_changed", unlocked_towers)
	print("GameManager: All game progress reset. Starting fresh.")
