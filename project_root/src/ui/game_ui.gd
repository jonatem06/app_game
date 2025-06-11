# src/ui/game_ui.gd
extends Control
class_name GameUI

# Referencias a los nodos de la UI (se asignan en _ready o desde el editor)
onready var lives_label: Label = $MarginContainer/VBoxContainer/InfoBar/LivesLabel
onready var coins_label: Label = $MarginContainer/VBoxContainer/InfoBar/CoinsLabel
onready var wave_label: Label = $MarginContainer/VBoxContainer/InfoBar/WaveLabel

onready var buy_warrior_button: Button = $MarginContainer/VBoxContainer/DefenderButtons/BuyWarriorButton
onready var buy_archer_button: Button = $MarginContainer/VBoxContainer/DefenderButtons/BuyArcherButton
onready var buy_mage_button: Button = $MarginContainer/VBoxContainer/DefenderButtons/BuyMageButton

# Podríamos tener un MessageLabel
# onready var message_label: Label = $MarginContainer/MessageLabel

# Referencias a GameManager, WaveManager (se podrían pasar o acceder como singletons)
var game_manager_node: Node # Asumimos que se asignará o será un Autoload/Singleton
var wave_manager_node: Node # Asumimos que se asignará o será un Autoload/Singleton

func _ready():
	# Conectar botones a sus funciones
	if buy_warrior_button: buy_warrior_button.connect("pressed", self, "_on_buy_defender_pressed", ["Warrior", 100])
	if buy_archer_button:  buy_archer_button.connect("pressed", self, "_on_buy_defender_pressed", ["Archer", 150])
	if buy_mage_button:    buy_mage_button.connect("pressed", self, "_on_buy_defender_pressed", ["Mage", 200])

	# Localizar GameManager y WaveManager
	# Esto es una forma común si son Autoloads (singletons globales)
	if get_tree().has_node("/root/GameManager"):
		game_manager_node = get_node("/root/GameManager")
	if get_tree().has_node("/root/WaveManager"): # Si WaveManager también es un singleton
		wave_manager_node = get_node("/root/WaveManager")

	# Conectar a señales de GameManager y WaveManager
	if game_manager_node:
		game_manager_node.connect("lives_changed", self, "_on_player_lives_changed")
		game_manager_node.connect("coins_changed", self, "_on_player_coins_changed")
		# Podríamos conectar "game_over" para mostrar un mensaje
		# game_manager_node.connect("game_over", self, "_on_game_over")
		# game_manager_node.connect("defender_purchase_approved", self, "_on_defender_purchase_approved") # Para feedback

		# Actualizar UI con valores iniciales del GameManager
		if game_manager_node.has_method("get_player_lives"):
			_on_player_lives_changed(game_manager_node.get_player_lives())
		if game_manager_node.has_method("get_player_coins"):
			_on_player_coins_changed(game_manager_node.get_player_coins())

	if wave_manager_node:
		wave_manager_node.connect("wave_started", self, "_on_wave_info_changed")
		wave_manager_node.connect("wave_completed", self, "_on_wave_info_changed") # Actualizar también al completar
		# Actualizar UI con valores iniciales del WaveManager
		if wave_manager_node.has_method("get_current_wave_number") and wave_manager_node.has_method("get_total_waves_for_level"):
			_on_wave_info_changed(wave_manager_node.get_current_wave_number(), wave_manager_node.get_total_waves_for_level())
	else: # Valores por defecto si no hay wave manager al inicio
		if wave_label: wave_label.text = "Wave: -/-"

	if not lives_label: printerr("LivesLabel not found for path: MarginContainer/VBoxContainer/InfoBar/LivesLabel")
	if not coins_label: printerr("CoinsLabel not found for path: MarginContainer/VBoxContainer/InfoBar/CoinsLabel")
	if not wave_label: printerr("WaveLabel not found for path: MarginContainer/VBoxContainer/InfoBar/WaveLabel")
	if not buy_warrior_button: printerr("BuyWarriorButton not found")
	if not buy_archer_button: printerr("BuyArcherButton not found")
	if not buy_mage_button: printerr("BuyMageButton not found")


func _on_player_lives_changed(new_lives: int):
	if lives_label: lives_label.text = "Lives: " + str(new_lives)

func _on_player_coins_changed(new_coins: int):
	if coins_label: coins_label.text = "Coins: " + str(new_coins)

func _on_wave_info_changed(current_wave_num: int, total_waves: int):
	if wave_label:
		if total_waves > 0:
			wave_label.text = "Wave: " + str(current_wave_num) + "/" + str(total_waves)
		else: # Nivel aún no iniciado o información no disponible
			wave_label.text = "Wave: -"


func _on_buy_defender_pressed(defender_type: String, defender_cost: int):
	if game_manager_node and game_manager_node.has_method("attempt_purchase_defender"):
		# La posición es un placeholder. En un juego real, el jugador seleccionaría una
		# celda en el mapa después de hacer clic en el botón.
		var placeholder_position = Vector2.ZERO
		print("UI: Attempting to buy " + defender_type + " for " + str(defender_cost) + " coins.")
		game_manager_node.attempt_purchase_defender(defender_type, defender_cost, placeholder_position)
	else:
		printerr("GameManager node not found or method missing, cannot buy defender.")
		# if message_label: message_label.text = "Error: GameManager not available."


# func _on_defender_purchase_approved(defender_type: String, cost: int, position: Vector2):
#	  if message_label: message_label.text = defender_type + " purchased!"
#	  # Aquí se podría entrar en un modo de colocación si no se hizo antes.

# func _on_game_over():
#	  if message_label: message_label.text = "GAME OVER!"
#	  # Podría deshabilitar botones de compra, etc.
