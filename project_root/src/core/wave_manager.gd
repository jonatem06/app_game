# src/core/wave_manager.gd
extends Node
class_name WaveManager

signal wave_started(wave_number, total_waves)
signal wave_completed(wave_number)
signal all_waves_completed
signal spawn_enemy(enemy_scene, spawn_position, path_points) # Para instanciar enemigos

var current_wave: int = 0
var total_waves_for_level: int = 0
var enemies_in_current_wave: Array = [] # Para rastrear enemigos activos en la oleada
var base_demons_count: int = 6
var demon_increment_per_wave: int = 6

# Referencias a otros nodos/escenas (se establecerían desde el editor o por código)
# var enemy_demon_scene: PackedScene # Escena del Demonio
# var enemy_demon_boss_scene: PackedScene # Escena del Jefe Demonio
# var path_generator: PathGenerator # Para obtener el camino

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	# Conectar señales si es necesario, por ejemplo, si los enemigos emiten una señal al morir
	# para poder rastrear cuándo la oleada ha terminado.

func setup_level(path_gen_node): # path_gen_node debería ser PathGenerator
	# self.path_generator = path_gen_node # Asignar si es necesario obtener el camino aquí
	current_wave = 0
	total_waves_for_level = rng.randi_range(4, 7)
	print("Level setup with " + str(total_waves_for_level) + " waves.")

func start_next_wave():
	if current_wave >= total_waves_for_level:
		emit_signal("all_waves_completed")
		print("All waves completed for this level!")
		return

	current_wave += 1
	enemies_in_current_wave.clear()

	print("Starting Wave " + str(current_wave) + "/" + str(total_waves_for_level))
	emit_signal("wave_started", current_wave, total_waves_for_level)

	# Determinar la composición de la oleada
	var demons_to_spawn = base_demons_count + (demon_increment_per_wave * (current_wave -1))
	var spawn_boss = false

	# Cada 2 olas normales, la siguiente tiene jefe. Ola 1, 2 (normales), Ola 3 (jefe), Ola 4, 5 (normales), Ola 6 (jefe)...
	# Esto significa que las olas 3, 6, 9, etc., tienen jefe.
	# Si current_wave es múltiplo de 3, es una ola con jefe.
	if current_wave % 3 == 0:
		spawn_boss = true

	# Lógica de spawn (simplificada, necesitará PackedScenes reales y un punto de spawn)
	# Asumimos que path_points se obtiene del PathGenerator
	# var spawn_pos = path_generator.get_path_points()[0] if path_generator and not path_generator.get_path_points().empty() else Vector2.ZERO
	# var p_points = path_generator.get_path_points() if path_generator else []

	# Esta es una simulación del spawn. En un juego real, se instanciarían escenas.
	# El WaveManager emitiría una señal para que otro nodo (GameManager/LevelManager)
	# realmente instancie las escenas de los enemigos.

	for i in range(demons_to_spawn):
		# Placeholder: En un juego real, se instanciaría una escena de Demonio.
		# var demon = enemy_demon_scene.instance()
		# add_child(demon) # O añadir a un contenedor de enemigos
		# demon.set_path(p_points)
		# demon.connect("tree_exiting", self, "_on_enemy_destroyed", [demon])
		# enemies_in_current_wave.append(demon)
		# emit_signal("spawn_enemy", enemy_demon_scene, spawn_pos, p_points)
		print("Spawning Demon " + str(i+1) + "/" + str(demons_to_spawn))


	if spawn_boss:
		# Placeholder: Instanciar escena de Jefe Demonio
		# var boss = enemy_demon_boss_scene.instance()
		# add_child(boss)
		# boss.set_path(p_points)
		# boss.connect("tree_exiting", self, "_on_enemy_destroyed", [boss])
		# enemies_in_current_wave.append(boss)
		# emit_signal("spawn_enemy", enemy_demon_boss_scene, spawn_pos, p_points)
		print("Spawning Demon Boss at the end of the wave.")

	if enemies_in_current_wave.empty() and demons_to_spawn == 0 and not spawn_boss:
		# Si por alguna razón la oleada está vacía (ej. 0 demonios y sin jefe), completarla.
		_check_wave_completion()


func _on_enemy_destroyed(enemy_node):
	if enemies_in_current_wave.has(enemy_node):
		enemies_in_current_wave.erase(enemy_node)

	_check_wave_completion()

func _check_wave_completion():
	if not enemies_in_current_wave.empty(): # Comprobar si todavía hay enemigos que se están rastreando.
		return

	# Si no hay enemigos rastreados, la oleada podría estar completa.
	# Aquí se necesitaría una comprobación más robusta, por ejemplo,
	# si el número de enemigos spawneados coincide con el número de enemigos destruidos.
	# Por ahora, si la lista `enemies_in_current_wave` está vacía después de que
	# todos los enemigos *deberían* haber sido spawneados y destruidos,
	# consideramos la oleada completa.
	# Esto es simplificado. Una mejor manera es contar cuántos se spawnean y cuántos se destruyen.

	# Para la simulación actual donde no instanciamos enemigos reales y no los añadimos a `enemies_in_current_wave`,
	# esta función se llamaría externamente cuando se detecte que todos los enemigos de la simulación han sido "derrotados".
	# O, para prueba, podemos llamarla directamente después del bucle de spawn si no hay enemigos reales.

	# Si todos los enemigos de la oleada actual han sido eliminados.
	if current_wave > 0 : # Solo si una oleada ha empezado
		print("Wave " + str(current_wave) + " completed.")
		emit_signal("wave_completed", current_wave)
		# Aquí se podría dar una pausa antes de la siguiente oleada o esperar input del jugador.
		# Por ahora, simplemente preparamos para la siguiente.
		# start_next_wave() # O manejar esto a través de una señal o temporizador.


# Esta función sería llamada por el sistema principal del juego cuando un enemigo es derrotado
# o sale del mapa.
func report_enemy_defeated(enemy):
	# Esta función es crucial para que el wave_manager sepa cuándo limpiar `enemies_in_current_wave`.
	# En la implementación actual de Attacker.gd, los enemigos se autoeliminan (queue_free).
	# Necesitamos conectar la señal `tree_exiting` de cada enemigo a `_on_enemy_destroyed`.
	# El código de ejemplo para esto está comentado en `start_next_wave`.
	# Sin esa conexión, `_on_enemy_destroyed` no se llamará automáticamente.
	_on_enemy_destroyed(enemy) # Simulación de la señal siendo recibida

# ----- Funciones para simulación y prueba (sin instanciar escenas) -----
var simulated_enemies_alive = 0

func start_next_wave_simulation(path_generator_ref):
	if current_wave >= total_waves_for_level:
		emit_signal("all_waves_completed")
		print("All waves completed for this level! (Simulation)")
		return

	current_wave += 1
	simulated_enemies_alive = 0 # Resetear contador para la simulación

	print("Starting Simulated Wave " + str(current_wave) + "/" + str(total_waves_for_level))
	emit_signal("wave_started", current_wave, total_waves_for_level)

	var demons_to_spawn = base_demons_count + (demon_increment_per_wave * (current_wave - 1))
	var spawn_boss = (current_wave % 3 == 0)

	var spawn_pos = Vector2.ZERO
	var p_points = []
	if path_generator_ref:
		p_points = path_generator_ref.get_path_points()
		if not p_points.empty():
			spawn_pos = p_points[0]

	if p_points.empty():
		printerr("WaveManager: Path points are empty. Cannot spawn enemies correctly.")
		# Considerar la oleada como fallida o vacía si no hay camino
		_check_wave_completion_simulation()
		return

	for i in range(demons_to_spawn):
		# Simular la emisión de la señal de spawn
		# emit_signal("spawn_enemy", "DemonScenePlaceholder", spawn_pos, p_points)
		print("Simulating spawn: Demon " + str(i+1) + " at " + str(spawn_pos) + " following " + str(p_points.size()) + " path points.")
		simulated_enemies_alive += 1

	if spawn_boss:
		# emit_signal("spawn_enemy", "DemonBossScenePlaceholder", spawn_pos, p_points)
		print("Simulating spawn: DemonBoss at " + str(spawn_pos))
		simulated_enemies_alive += 1

	print("Simulated wave " + str(current_wave) + " has " + str(simulated_enemies_alive) + " enemies.")
	if simulated_enemies_alive == 0: # Si la oleada está vacía
		_check_wave_completion_simulation()

# En la simulación, esto se llamaría externamente para indicar que un enemigo fue "derrotado"
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
		# En una simulación, podríamos querer iniciar la siguiente oleada automáticamente
		# o esperar una señal para hacerlo.
	elif current_wave == 0:
		print("Wave manager reset or not started.")

func get_current_wave_number() -> int:
	return current_wave

func get_total_waves_for_level() -> int:
	return total_waves_for_level

func get_simulated_enemies_alive() -> int:
	return simulated_enemies_alive
