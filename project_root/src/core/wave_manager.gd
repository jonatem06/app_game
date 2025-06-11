# src/core/wave_manager.gd
extends Node
class_name WaveManager

# Modificar señal para incluir la vida del enemigo a spawnear
signal wave_started(wave_number, total_waves)
signal wave_completed(wave_number)
signal all_waves_completed
# La señal ahora también puede llevar la vida calculada para el enemigo
signal spawn_enemy(enemy_type_placeholder: String, spawn_position: Vector2, path_points: Array, calculated_health: float)

var current_wave: int = 0
var total_waves_for_level: int = 0
var enemies_in_current_wave: Array = []
var base_demons_count: int = 6
var demon_increment_per_wave: int = 6

var base_demon_health: float = 40.0
var demon_health_increment_per_wave: float = 5.0

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func setup_level(path_gen_node):
	current_wave = 0
	# total_waves_for_level = rng.randi_range(4, 7) # Original
	total_waves_for_level = rng.randi_range(3, 5) # Ajustado para probar jefe en ola 3 más rápido
	# print("Level setup with " + str(total_waves_for_level) + " waves.") # Redundant if MainGame prints level name

func start_next_wave():
	if current_wave >= total_waves_for_level:
		emit_signal("all_waves_completed")
		print("All waves completed for this level!")
		return

	current_wave += 1
	enemies_in_current_wave.clear()

	print("Starting Wave " + str(current_wave) + "/" + str(total_waves_for_level))
	emit_signal("wave_started", current_wave, total_waves_for_level)

	var demons_to_spawn = base_demons_count + (demon_increment_per_wave * (current_wave -1))
	var spawn_boss = (current_wave % 3 == 0)

	var calculated_demon_health = base_demon_health + (demon_health_increment_per_wave * (current_wave - 1))
	if calculated_demon_health < base_demon_health:
		calculated_demon_health = base_demon_health

	# Simulación de spawn real - necesitaría path_generator y enemy scenes
	# var spawn_pos = path_generator.get_path_points()[0] if path_generator and not path_generator.get_path_points().empty() else Vector2.ZERO
	# var p_points = path_generator.get_path_points() if path_generator else []

	for i in range(demons_to_spawn):
		# emit_signal("spawn_enemy", enemy_demon_scene, spawn_pos, p_points, calculated_demon_health) # Para instanciación real
		print("Spawning Demon " + str(i+1) + "/" + str(demons_to_spawn) + " with health " + str(calculated_demon_health))
		# Placeholder para instanciación y seguimiento real:
		# var demon = enemy_demon_scene.instance()
		# setup_enemy(demon, p_points, calculated_demon_health)


	if spawn_boss:
		# emit_signal("spawn_enemy", enemy_demon_boss_scene, spawn_pos, p_points, -1.0) # -1 para vida por defecto
		print("Spawning Demon Boss (using its default health).")
		# Placeholder para instanciación y seguimiento real:
		# var boss = enemy_demon_boss_scene.instance()
		# setup_enemy(boss, p_points, -1.0) # -1 para indicar que use su vida base

	if enemies_in_current_wave.empty() and demons_to_spawn == 0 and not spawn_boss:
		_check_wave_completion() # O _check_wave_completion_simulation para la version simulada

# func setup_enemy(enemy_node, path, health):
#	 add_child(enemy_node) # O añadir a un contenedor de enemigos
#	 enemy_node.set_path(path)
#	 if health > 0 and enemy_node.has_method("set_health"): # Suponiendo un método set_health o pasar en _init
#	 	 # Esto es conceptual, Attacker._init ya maneja la salud.
#        # La instanciación en MainGame se encargará de esto.
#	     pass
#	 enemy_node.connect("tree_exiting", self, "_on_enemy_destroyed", [enemy_node])
#	 enemies_in_current_wave.append(enemy_node)

func _on_enemy_destroyed(enemy_node):
	if enemies_in_current_wave.has(enemy_node):
		enemies_in_current_wave.erase(enemy_node)
	_check_wave_completion()

func _check_wave_completion():
	if not enemies_in_current_wave.empty():
		return
	if current_wave > 0 :
		print("Wave " + str(current_wave) + " completed.")
		emit_signal("wave_completed", current_wave)

func report_enemy_defeated(enemy):
	_on_enemy_destroyed(enemy)

var simulated_enemies_alive = 0

func start_next_wave_simulation(path_generator_ref):
	if current_wave >= total_waves_for_level:
		emit_signal("all_waves_completed")
		print("All waves completed for this level! (Simulation)")
		return

	current_wave += 1
	simulated_enemies_alive = 0

	print("Starting Simulated Wave " + str(current_wave) + "/" + str(total_waves_for_level))
	emit_signal("wave_started", current_wave, total_waves_for_level)

	var demons_to_spawn = base_demons_count + (demon_increment_per_wave * (current_wave - 1))
	var spawn_boss = (current_wave % 3 == 0)

	# Obtener multiplicador de dificultad de GameManager (Autoload)
	var difficulty_mult: float = 1.0 # Renamed for clarity
	if GameManager: # Chequear si el Autoload está disponible
		difficulty_mult = GameManager.get_difficulty_multiplier() # Usar el getter general
	else:
		printerr("WaveManager: GameManager Autoload not found! Defaulting difficulty multiplier to 1.0")

	var calculated_demon_health_base_for_wave = base_demon_health + (demon_health_increment_per_wave * (current_wave - 1))
	if calculated_demon_health_base_for_wave < base_demon_health:
		calculated_demon_health_base_for_wave = base_demon_health

	# Aplicar multiplicador de dificultad
	var final_demon_health_for_wave = calculated_demon_health_base_for_wave * difficulty_mult

	var spawn_pos = Vector2.ZERO
	var p_points = []
	if path_generator_ref:
		p_points = path_generator_ref.get_path_points()
		if not p_points.empty():
			spawn_pos = p_points[0]

	if p_points.empty():
		printerr("WaveManager: Path points are empty. Cannot spawn enemies correctly.")
		_check_wave_completion_simulation()
		return

	for i in range(demons_to_spawn):
		emit_signal("spawn_enemy", "DemonScenePlaceholder", spawn_pos, p_points, final_demon_health_for_wave)
		# print("WaveManager: Simulating spawn: Demon " + str(i+1) + " with health " + str(final_demon_health_for_wave)) # MainGame logs this
		simulated_enemies_alive += 1

	if spawn_boss:
		# La vida del jefe también podría escalar con dificultad si quisiéramos.
		# Por ahora, el jefe usa su vida por defecto (-1.0 signal).
		# Si quisiéramos que escale:
		var boss_base_hp = 200.0 # Asumiendo que DemonBoss.gd tiene 200 por defecto o leerlo de una constante
		# Si DemonBoss tiene una constante `BASE_HEALTH` podríamos usarla:
		# var boss_script = load("res://src/core/entities/attackers/demon_boss.gd")
		# if boss_script and boss_script.has_constant("BASE_HEALTH"): boss_base_hp = boss_script.BASE_HEALTH
		var final_boss_health = boss_base_hp * difficulty_mult # Usar el multiplicador general
		emit_signal("spawn_enemy", "DemonBossScenePlaceholder", spawn_pos, p_points, final_boss_health)
		# print("WaveManager: Simulating spawn: DemonBoss (default HP * diff mult = " + str(final_boss_health) +").") # MainGame logs this
		simulated_enemies_alive += 1

	# print("Simulated wave " + str(current_wave) + " has " + str(simulated_enemies_alive) + " enemies.") # Verbose
	if simulated_enemies_alive == 0:
		_check_wave_completion_simulation()

func report_simulated_enemy_defeated():
	if simulated_enemies_alive > 0:
		simulated_enemies_alive -= 1
		print("Simulated enemy defeated. Remaining: " + str(simulated_enemies_alive))

	if simulated_enemies_alive == 0 and current_wave > 0:
		_check_wave_completion_simulation()

func _check_wave_completion_simulation():
	if simulated_enemies_alive == 0 and current_wave > 0:
		print("Simulated Wave " + str(current_wave) + " completed.")
		emit_signal("wave_completed", current_wave)
	elif current_wave == 0:
		print("Wave manager reset or not started.")

func get_current_wave_number() -> int:
	return current_wave

func get_total_waves_for_level() -> int:
	return total_waves_for_level

func get_simulated_enemies_alive() -> int:
	return simulated_enemies_alive

# Nueva función que podría ser usada por MainGame si WaveManager maneja la lista real de enemigos
# func report_enemy_defeated_for_tracking(enemy_node):
#	 if enemies_in_current_wave.has(enemy_node):
#		 enemies_in_current_wave.erase(enemy_node)
#		 print("WaveManager: Tracked enemy removed: " + enemy_node.name + ". Remaining tracked: " + str(enemies_in_current_wave.size()))
#	 _check_wave_completion()
