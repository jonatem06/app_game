# src/levels/level_configuration.gd
extends Resource
class_name LevelConfiguration

export var level_name: String = "Default Level"

# Dimensiones del mapa para PathGenerator
export var grid_width: int = 20
export var grid_height: int = 15

# Parámetros del PathGenerator
export var path_seed: int = 0 # 0 para aleatorio, otro valor para semilla fija
# Podríamos añadir start_point y end_point si quisiéramos anular los por defecto
# export var custom_start_point: Vector2 = Vector2(-1, -1) # (-1,-1) para usar por defecto
# export var custom_end_point: Vector2 = Vector2(-1, -1)

# Configuración de Oleadas (WaveManager)
# -1 para usar el aleatorio por defecto de WaveManager (4-7)
export var number_of_waves: int = -1
# Podríamos añadir arrays para definir composiciones específicas de oleadas si es necesario
# export var custom_wave_definitions: Array = []

# Podríamos añadir más propiedades, como:
# - Monedas iniciales específicas para el nivel (anularía GameManager.reset_level_state())
# - Defensores permitidos/restringidos
# - Música de fondo específica del nivel

func _init():
	# Valores por defecto pueden establecerse aquí también si no se usa `export` con valor inicial
	pass
