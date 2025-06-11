# src/ui/game_ui.gd
extends Control
class_name GameUI

onready var lives_label: Label = $MarginContainer/VBoxContainer/InfoBar/LivesLabel
onready var coins_label: Label = $MarginContainer/VBoxContainer/InfoBar/CoinsLabel
onready var wave_label: Label = $MarginContainer/VBoxContainer/InfoBar/WaveLabel

onready var buy_warrior_button: Button = $MarginContainer/VBoxContainer/DefenderButtons/BuyWarriorButton
onready var buy_archer_button: Button = $MarginContainer/VBoxContainer/DefenderButtons/BuyArcherButton
onready var buy_mage_button: Button = $MarginContainer/VBoxContainer/DefenderButtons/BuyMageButton

var game_manager_node: Node
var wave_manager_node: Node

# Almacenar los botones en un diccionario para fácil acceso por tipo de torre
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

	if get_tree().has_node("/root/GameManager"):
		game_manager_node = get_node("/root/GameManager")
	if get_tree().has_node("/root/WaveManager"): # Si WaveManager también es un singleton
		wave_manager_node = get_node("/root/WaveManager")

	if game_manager_node:
		game_manager_node.connect("lives_changed", self, "_on_player_lives_changed")
		game_manager_node.connect("coins_changed", self, "_on_player_coins_changed")
		game_manager_node.connect("towers_unlocked_changed", self, "_on_towers_unlocked_changed") # Nueva conexión

		if game_manager_node.has_method("get_player_lives"):
			_on_player_lives_changed(game_manager_node.get_player_lives())
		if game_manager_node.has_method("get_player_coins"):
			_on_player_coins_changed(game_manager_node.get_player_coins())
		# Actualizar estado inicial de botones de torres
		if game_manager_node.has_method("get_unlocked_towers"):
			_on_towers_unlocked_changed(game_manager_node.get_unlocked_towers())
		else: # Fallback si el método no existe aún (durante desarrollo) o GM no está listo
			_on_towers_unlocked_changed([])


	if wave_manager_node:
		wave_manager_node.connect("wave_started", self, "_on_wave_info_changed")
		wave_manager_node.connect("wave_completed", self, "_on_wave_info_changed")
		if wave_manager_node.has_method("get_current_wave_number") and wave_manager_node.has_method("get_total_waves_for_level"):
			_on_wave_info_changed(wave_manager_node.get_current_wave_number(), wave_manager_node.get_total_waves_for_level())
	else:
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
		else:
			wave_label.text = "Wave: -"


func _on_buy_defender_pressed(defender_type: String, defender_cost: int):
	if game_manager_node and game_manager_node.has_method("is_tower_unlocked"):
		if not game_manager_node.is_tower_unlocked(defender_type):
			print("UI: Attempt to buy locked tower '" + defender_type + "'. This should not happen if buttons are correctly disabled.")
			return

	if game_manager_node and game_manager_node.has_method("attempt_purchase_defender"):
		var placeholder_position = Vector2.ZERO
		# print("UI: Attempting to buy " + defender_type + " for " + str(defender_cost) + " coins.") # Un poco verboso
		game_manager_node.attempt_purchase_defender(defender_type, defender_cost, placeholder_position)
	else:
		printerr("GameManager node not found or method missing, cannot buy defender.")

func _on_towers_unlocked_changed(p_unlocked_towers: Array):
	print("UI: Updating tower buttons based on unlocked towers: " + str(p_unlocked_towers))
	for tower_type in defender_buttons:
		var button_node = defender_buttons[tower_type]
		if is_instance_valid(button_node):
			if tower_type in p_unlocked_towers:
				button_node.disabled = false
				button_node.visible = true
				# print("UI: Button for " + tower_type + " enabled.")
			else:
				button_node.disabled = true
				# button_node.visible = false # Opcional: ocultar en lugar de solo deshabilitar
				# print("UI: Button for " + tower_type + " disabled.")
		else:
			printerr("UI: Button node for " + tower_type + " is not valid in defender_buttons dictionary.")
