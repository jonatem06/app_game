# src/main_game.gd
extends Node
class_name MainGame

# Añadir export para la configuración del nivel
export var level_config_path: String = "res://src/levels/level_1.tres" # Ruta por defecto al primer nivel
var current_level_config: LevelConfiguration

# --- NODOS HIJOS ESPERADOS ---
onready var tile_map_node: TileMap = get_node_or_null("GameBoard/TileMap")
onready var defenders_container: Node2D = get_node_or_null("GameBoard/Defenders")

# --- MANAGERS ---
var wave_manager_node: WaveManager
var path_generator_node: PathGenerator

var current_level_path: Array = []
# var grid_size = Vector2(20, 15) # Removido, se tomará de level_config

# --- ESCENAS DE UNIDADES (PackedScene) ---
var warrior_scene: PackedScene = preload("res://src/core/entities/defenders/warrior.tscn")
var archer_scene: PackedScene = preload("res://src/core/entities/defenders/archer.tscn")
var mage_scene: PackedScene = preload("res://src/core/entities/defenders/mage.tscn")

# --- CONSTANTES PARA TILEMAP (ejemplo) ---
const TILE_EMPTY = -1
const TILE_GRASS = 0
const TILE_PATH = 1

func _ready():
	print("MainGame: _ready() called.")

	# Cargar la configuración del nivel
	if level_config_path.empty():
		printerr("MainGame: Level configuration path is empty!")
		current_level_config = LevelConfiguration.new()
		print("MainGame: Using default LevelConfiguration.")
	else:
		current_level_config = load(level_config_path)
		if not current_level_config:
			printerr("MainGame: Failed to load level configuration from: " + level_config_path)
			current_level_config = LevelConfiguration.new()
			print("MainGame: Using default LevelConfiguration due to load failure.")
		else:
			print("MainGame: Loaded level configuration: " + current_level_config.level_name)

	# Asegurarse de que los nodos esperados existan
	if not tile_map_node:
		printerr("MainGame: TileMap node not found! Please add a TileMap at GameBoard/TileMap.")
	if not defenders_container:
		printerr("MainGame: Defenders container node not found! Please add a Node2D at GameBoard/Defenders.")

	path_generator_node = PathGenerator.new()
	path_generator_node.name = "PathGeneratorInstance"
	add_child(path_generator_node)

	wave_manager_node = WaveManager.new()
	wave_manager_node.name = "WaveManagerInstance"
	add_child(wave_manager_node)

	connect_signals()
	start_new_level()

func connect_signals():
	print("MainGame: Connecting signals...")
	GameManager.connect("game_over", self, "_on_game_over")
	GameManager.connect("defender_purchase_approved", self, "_on_defender_purchase_approved")

	if wave_manager_node:
		wave_manager_node.connect("spawn_enemy", self, "_on_spawn_enemy")
		wave_manager_node.connect("all_waves_completed", self, "_on_all_waves_completed")
	else:
		printerr("MainGame: WaveManager node not found during signal connection.")
	print("MainGame: Signal connections attempted.")

func start_new_level():
	print("MainGame: Starting new level - " + current_level_config.level_name)
	GameManager.reset_level_state()

	if path_generator_node:
		path_generator_node.grid_width = current_level_config.grid_width
		path_generator_node.grid_height = current_level_config.grid_height
		if current_level_config.path_seed != 0:
			path_generator_node.set_random_seed(current_level_config.path_seed)
		# else: path_generator_node.rng.randomize() # Si se quiere asegurar aleatoriedad si seed es 0

		current_level_path = path_generator_node.generate_path()
		if current_level_path.empty():
			printerr("MainGame: Path generation failed for level " + current_level_config.level_name)
			return
		print("MainGame: Path generated for " + current_level_config.level_name + " with " + str(current_level_path.size()) + " points.")
		configure_tilemap_from_path(current_level_path, Vector2(current_level_config.grid_width, current_level_config.grid_height))
	else:
		printerr("MainGame: PathGenerator not available.")
		return

	if wave_manager_node:
		wave_manager_node.setup_level(path_generator_node)
		if current_level_config.number_of_waves > 0:
			wave_manager_node.total_waves_for_level = current_level_config.number_of_waves

		wave_manager_node.start_next_wave_simulation(path_generator_node)
	else:
		printerr("MainGame: WaveManager not available.")

func _on_game_over():
	print("MainGame: Received game_over signal from GameManager.")
	get_tree().paused = true

func _on_all_waves_completed():
	print("MainGame: All waves completed! Level Won!")
	# get_tree().paused = true # Opcional

	# Ejemplo de desbloqueo de torre al ganar un nivel
	# Podríamos tener una lógica más compleja (ej: qué nivel desbloquea qué)
	if current_level_config and current_level_config.level_name == "The First Stand": # Si ganamos el Nivel 1
		if GameManager.has_method("unlock_tower"):
			GameManager.unlock_tower("Archer")
	elif current_level_config and current_level_config.level_name == "The Winding Path": # Si ganamos el Nivel 2
		 if GameManager.has_method("unlock_tower"):
			GameManager.unlock_tower("Mage")

	# Aquí se podría cargar el siguiente nivel o ir a una pantalla de victoria/mapa de niveles.

func _on_defender_purchase_approved(defender_type_string: String, cost: int, grid_click_position: Vector2):
	print("MainGame: Received defender_purchase_approved for " + defender_type_string + " at map click (simulated): " + str(grid_click_position))

	if not tile_map_node:
		printerr("MainGame: Cannot place defender, TileMap not found.")
		GameManager.add_coins(cost)
		return

	var cell_coords: Vector2 = grid_click_position
	if grid_click_position == Vector2.ZERO:
		cell_coords = Vector2(5,5)
		print("MainGame: grid_click_position was ZERO, attempting test placement at cell " + str(cell_coords))

	var tile_id = tile_map_node.get_cellv(cell_coords)
	var can_place = false
	if tile_id == TILE_GRASS:
		can_place = true
	else:
		var tile_name = tile_map_node.tile_set.tile_get_name(tile_id) if tile_map_node.tile_set else "Unknown"
		print("MainGame: Cannot place defender on cell " + str(cell_coords) + ". Tile ID: " + str(tile_id) + " (Name: "+tile_name+"). Expected TILE_GRASS ("+str(TILE_GRASS)+").")

	if not can_place:
		print("MainGame: Placement at " + str(cell_coords) + " is invalid.")
		GameManager.add_coins(cost)
		return

	var defender_instance: Node2D = null
	match defender_type_string:
		"Warrior":
			defender_instance = warrior_scene.instance() if warrior_scene else null
		"Archer":
			defender_instance = archer_scene.instance() if archer_scene else null
		"Mage":
			defender_instance = mage_scene.instance() if mage_scene else null

	if not defender_instance:
		printerr("MainGame: Could not instance defender scene for type: " + defender_type_string)
		GameManager.add_coins(cost)
		return

	if defenders_container:
		defenders_container.add_child(defender_instance)
	else:
		add_child(defender_instance)

	var world_pos = tile_map_node.map_to_world(cell_coords) + tile_map_node.cell_size / 2
	defender_instance.position = world_pos

	print("MainGame: Placed " + defender_type_string + " at cell " + str(cell_coords) + " (world pos: " + str(world_pos) + ")")

func _on_spawn_enemy(enemy_type_placeholder: String, spawn_position: Vector2, path_points: Array, calculated_health: float):
	var enemy_instance: Attacker = null
	var enemy_script = null

	if enemy_type_placeholder == "DemonScenePlaceholder":
		enemy_script = load("res://src/core/entities/attackers/demon.gd")
		if enemy_script:
			if calculated_health > 0:
				enemy_instance = enemy_script.new(calculated_health)
			else:
				enemy_instance = enemy_script.new()
	elif enemy_type_placeholder == "DemonBossScenePlaceholder":
		enemy_script = load("res://src/core/entities/attackers/demon_boss.gd")
		if enemy_script:
			enemy_instance = enemy_script.new()

	if enemy_instance:
		add_child(enemy_instance)
		enemy_instance.set_position(spawn_position)
		enemy_instance.set_path(path_points)
		enemy_instance.connect("attacker_reached_end", GameManager, "enemy_reached_castle")
		enemy_instance.connect("attacker_died_give_reward", GameManager, "add_coins")
		enemy_instance.add_to_group("attackers")
		print("MainGame: Spawned " + enemy_instance.name + " (Actual HP: " + str(enemy_instance.health) + ") at " + str(spawn_position))
	else:
		printerr("MainGame: Could not instantiate enemy from placeholder: " + enemy_type_placeholder)

func configure_tilemap_from_path(path: Array, p_grid_size: Vector2): # Nuevo parámetro p_grid_size
	if not tile_map_node:
		printerr("MainGame: TileMap not found, cannot configure path on it.")
		return

	tile_map_node.clear()

	for x in range(p_grid_size.x):
		for y in range(p_grid_size.y):
			tile_map_node.set_cell(x, y, TILE_GRASS)

	for point_in_path in path:
		var cell_coords = Vector2(int(point_in_path.x), int(point_in_path.y))
		if cell_coords.x >= 0 and cell_coords.x < p_grid_size.x and cell_coords.y >= 0 and cell_coords.y < p_grid_size.y:
			tile_map_node.set_cellv(cell_coords, TILE_PATH)
		else:
			printerr("MainGame: Path point " + str(cell_coords) + " is outside grid boundaries during TileMap configuration.")
	print("MainGame: TileMap configured for " + current_level_config.level_name + " with grass and path.")
