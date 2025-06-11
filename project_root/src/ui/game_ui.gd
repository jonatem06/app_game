# src/ui/game_ui.gd
extends Control
class_name GameUI

onready var lives_label: Label = $MarginContainer/VBoxContainer/InfoBar/LivesLabel
onready var coins_label: Label = $MarginContainer/VBoxContainer/InfoBar/CoinsLabel
onready var wave_label: Label = $MarginContainer/VBoxContainer/InfoBar/WaveLabel

onready var buy_warrior_button: Button = $MarginContainer/VBoxContainer/DefenderButtons/BuyWarriorButton
onready var buy_archer_button: Button = $MarginContainer/VBoxContainer/DefenderButtons/BuyArcherButton
onready var buy_mage_button: Button = $MarginContainer/VBoxContainer/DefenderButtons/BuyMageButton

# UI para Dificultad (asumir que existe un HBoxContainer "DifficultyBar" con estos nodos)
onready var difficulty_label: Label = $MarginContainer/VBoxContainer/DifficultyBar/DifficultyLabel # Nuevo
onready var normal_diff_button: Button = $MarginContainer/VBoxContainer/DifficultyBar/NormalButton # Nuevo
onready var difficult_diff_button: Button = $MarginContainer/VBoxContainer/DifficultyBar/DifficultButton # Nuevo
onready var hard_diff_button: Button = $MarginContainer/VBoxContainer/DifficultyBar/HardButton # Nuevo

var game_manager_node: Node
var wave_manager_node: Node
var defender_buttons: Dictionary = {}


func _ready():
	defender_buttons = {
		"Warrior": buy_warrior_button,
		"Archer": buy_archer_button,
		"Mage": buy_mage_button
	}

	if buy_warrior_button: buy_warrior_button.connect("pressed", self, "_on_buy_defender_pressed", ["Warrior", 100])
	if buy_archer_button:  buy_archer_button.connect("pressed", self, "_on_buy_defender_pressed", ["Archer", 150])
	if buy_mage_button:    buy_mage_button.connect("pressed", self, "_on_buy_defender_pressed", ["Mage", 200])

	# Conexiones para botones de dificultad
	if normal_diff_button: normal_diff_button.connect("pressed", self, "_on_difficulty_button_pressed", [GameManager.Difficulty.NORMAL])
	if difficult_diff_button: difficult_diff_button.connect("pressed", self, "_on_difficulty_button_pressed", [GameManager.Difficulty.DIFFICULT])
	if hard_diff_button: hard_diff_button.connect("pressed", self, "_on_difficulty_button_pressed", [GameManager.Difficulty.HARD])

	if get_tree().has_node("/root/GameManager"):
		game_manager_node = get_node("/root/GameManager")
	if get_tree().has_node("/root/WaveManager"):
		wave_manager_node = get_node("/root/WaveManager")

	if game_manager_node:
		game_manager_node.connect("lives_changed", self, "_on_player_lives_changed")
		game_manager_node.connect("coins_changed", self, "_on_player_coins_changed")
		game_manager_node.connect("towers_unlocked_changed", self, "_on_towers_unlocked_changed")
		game_manager_node.connect("difficulty_changed", self, "_on_difficulty_changed") # Nueva conexión

		if game_manager_node.has_method("get_player_lives"):
			_on_player_lives_changed(game_manager_node.get_player_lives())
		if game_manager_node.has_method("get_player_coins"):
			_on_player_coins_changed(game_manager_node.get_player_coins())
		if game_manager_node.has_method("get_unlocked_towers"):
			_on_towers_unlocked_changed(game_manager_node.get_unlocked_towers())
		else:
			_on_towers_unlocked_changed([])
		# Actualizar UI de dificultad inicial
		if game_manager_node.has_method("get_current_difficulty_enum") and game_manager_node.has_method("get_health_difficulty_multiplier"):
			 _on_difficulty_changed(game_manager_node.get_current_difficulty_enum(), game_manager_node.get_health_difficulty_multiplier())


	if wave_manager_node:
		wave_manager_node.connect("wave_started", self, "_on_wave_info_changed")
		wave_manager_node.connect("wave_completed", self, "_on_wave_info_changed")
		if wave_manager_node.has_method("get_current_wave_number") and wave_manager_node.has_method("get_total_waves_for_level"):
			_on_wave_info_changed(wave_manager_node.get_current_wave_number(), wave_manager_node.get_total_waves_for_level())
	else:
		if wave_label: wave_label.text = "Wave: -/-"

	# Chequeos de nodos de UI
	if not lives_label: printerr("LivesLabel not found")
	if not coins_label: printerr("CoinsLabel not found")
	if not wave_label: printerr("WaveLabel not found")
	if not buy_warrior_button: printerr("BuyWarriorButton not found")
	if not buy_archer_button: printerr("BuyArcherButton not found")
	if not buy_mage_button: printerr("BuyMageButton not found")
	if not difficulty_label: printerr("DifficultyLabel not found")
	if not normal_diff_button: printerr("NormalDiffButton not found")
	if not difficult_diff_button: printerr("DifficultDiffButton not found")
	if not hard_diff_button: printerr("HardDiffButton not found")


func _on_player_lives_changed(new_lives: int):
	if lives_label: lives_label.text = "Lives: " + str(new_lives)

func _on_player_coins_changed(new_coins: int):
	if coins_label: coins_label.text = "Coins: " + str(new_coins)

func _on_wave_info_changed(current_wave_num: int, total_waves: int):
	if wave_label:
		if total_waves > 0: wave_label.text = "Wave: " + str(current_wave_num) + "/" + str(total_waves)
		else: wave_label.text = "Wave: -"

func _on_buy_defender_pressed(defender_type: String, defender_cost: int):
	if game_manager_node and game_manager_node.has_method("is_tower_unlocked"):
		if not game_manager_node.is_tower_unlocked(defender_type):
			return
	if game_manager_node and game_manager_node.has_method("attempt_purchase_defender"):
		game_manager_node.attempt_purchase_defender(defender_type, defender_cost, Vector2.ZERO)
	else:
		printerr("GameManager node not found or method missing, cannot buy defender.")

func _on_towers_unlocked_changed(p_unlocked_towers: Array):
	# print("UI: Updating tower buttons based on unlocked towers: " + str(p_unlocked_towers)) # Verbose
	for tower_type in defender_buttons:
		var button_node = defender_buttons[tower_type]
		if is_instance_valid(button_node):
			button_node.disabled = not (tower_type in p_unlocked_towers)
			button_node.visible = (tower_type in p_unlocked_towers) # Opcional: completamente ocultar
		else:
			printerr("UI: Button node for " + tower_type + " is not valid in defender_buttons dictionary.")

func _on_difficulty_button_pressed(difficulty_enum_val: int):
	if game_manager_node: # GameManager es Autoload
		GameManager.set_difficulty(difficulty_enum_val)
		# Nota: Cambiar dificultad a mitad de nivel podría tener efectos raros si no se maneja
		# el reseteo de monedas/vida de enemigos inmediatamente. GameManager.set_difficulty
		# actualiza las monedas del jugador, pero no afecta enemigos ya spawneados.
		# Idealmente, esto se setea antes de empezar un nivel.

func _on_difficulty_changed(new_difficulty_enum: int, general_multiplier: float): # Parámetro renombrado
	if difficulty_label:
		# Asegurarse de que GameManager y su enum Difficulty estén disponibles
		if GameManager and "Difficulty" in GameManager:
			var diff_text = GameManager.Difficulty.keys()[new_difficulty_enum]
			# Mostrar el multiplicador general que afecta tanto a monedas como a vida enemiga
			difficulty_label.text = "Dificultad: " + diff_text + " (x" + str(general_multiplier) + ")"
		else:
			difficulty_label.text = "Dificultad: N/A"
			printerr("UI: GameManager or GameManager.Difficulty enum not found for updating difficulty label.")
	# print("UI: Difficulty changed callback - Enum: " + str(new_difficulty_enum) + ", Multiplier: " + str(general_multiplier)) # Redundant with label
