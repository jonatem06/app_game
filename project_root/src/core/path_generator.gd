# src/core/path_generator.gd
extends Node
class_name PathGenerator

# Define la semilla para la generación aleatoria, permitiendo caminos reproducibles si es necesario.
var random_seed = 0 setget set_random_seed
var rng = RandomNumberGenerator.new()

# Define el tamaño de la cuadrícula del mapa.
var grid_width = 20
var grid_height = 15 # Típicamente los juegos de torre de defensa son más anchos que altos

# Define los puntos de inicio y fin del camino.
# Estos podrían ser aleatorios en los bordes o fijos.
# Por ahora, fijaremos un inicio a la izquierda y un final a la derecha (castillo).
var start_point = Vector2(0, grid_height / 2)
var end_point = Vector2(grid_width - 1, grid_height / 2) # Castillo

# Almacena los puntos del camino.
var path_points = []

func _init(width = 20, height = 15):
    self.grid_width = width
    self.grid_height = height
    # Asegurar que el punto de inicio y fin estén dentro de los límites
    self.start_point = Vector2(0, int(grid_height / 2))
    self.end_point = Vector2(grid_width - 1, int(grid_height / 2))
    rng.seed = random_seed

func set_random_seed(value):
    random_seed = value
    rng.seed = random_seed

# Genera un camino desde start_point hasta end_point.
# Retorna un array de Vector2 representando las coordenadas del camino.
func generate_path():
    path_points.clear()
    var current_pos = start_point
    path_points.append(current_pos)

    var attempts = 0
    var max_attempts = grid_width * grid_height * 2 # Límite para evitar bucles infinitos

    while current_pos != end_point and attempts < max_attempts:
        var next_moves = []
        # Movimientos posibles: arriba, abajo, izquierda, derecha
        var potential_moves = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]

        # Priorizar movimientos hacia el end_point
        var direction_to_end = (end_point - current_pos).normalized()
        # potential_moves.sort_custom(SortByDirection, "compare_directions") # Necesita una clase para ordenar

        var moved = false
        for move_delta in potential_moves:
            var next_pos = current_pos + move_delta
            if is_valid_move(next_pos) and not is_path_segment_too_close(next_pos):
                # Evitar que el camino se cruce a sí mismo inmediatamente o cree áreas muy pequeñas
                current_pos = next_pos
                path_points.append(current_pos)
                moved = true
                break

        if not moved:
            # Si no se pudo mover (atrapado), intentar retroceder un poco o buscar alternativa.
            # Para una implementación simple, podríamos fallar o intentar un reinicio con otra semilla.
            # Por ahora, si se atasca, el camino podría no ser óptimo o completo.
            # Una solución más robusta usaría A* o similar.
            # En este caso, simplemente nos detenemos para evitar un bucle si no hay movimiento.
            printerr("Path generation got stuck at: ", current_pos)
            break
        attempts += 1

    if current_pos != end_point:
        printerr("Failed to generate a complete path to the end point.")
        # Podríamos intentar conectar directamente al final si está cerca, o marcar como fallido.
        # Por ahora, si no llega, el camino estará incompleto.
        # Una mejora sería añadir un paso final para forzar la conexión si es posible.

    # Asegurar que el último punto sea el end_point si se alcanzó o está cerca
    if not path_points.empty() and path_points[path_points.size() -1] != end_point and current_pos == end_point :
        if path_points[path_points.size() -1] != end_point:
             # Si el último punto no es el final, pero current_pos sí lo es, añadirlo.
             # Esto puede ocurrir si el bucle termina porque current_pos == end_point
             pass # Ya está cubierto por el append dentro del bucle
    elif path_points.empty() or path_points[path_points.size() -1] != end_point:
         # Si el camino está vacío o el último punto no es el final (y current_pos tampoco lo era)
         # intentar añadir el end_point de forma forzada si es adyacente al último punto válido.
         # Esta es una heurística muy simple.
         if not path_points.empty():
             var last_p = path_points[path_points.size()-1]
             if abs(last_p.x - end_point.x) <=1 and abs(last_p.y - end_point.y) <=1 :
                 path_points.append(end_point)
             else:
                 printerr("Could not force end point connection.")
         else:
             # Si el camino está vacío, añadir al menos inicio y fin
             path_points.append(start_point)
             path_points.append(end_point)


    print("Path generated: ", path_points)
    return path_points

# Verifica si una posición está dentro de los límites de la cuadrícula.
func is_valid_move(pos: Vector2) -> bool:
    return pos.x >= 0 and pos.x < grid_width and \
           pos.y >= 0 and pos.y < grid_height

# Verifica si un nuevo segmento del camino está demasiado cerca de segmentos existentes
# (excepto el inmediatamente anterior). Esto es para evitar que el camino se "toque"
# a sí mismo de forma extraña o cree bucles pequeños.
func is_path_segment_too_close(pos: Vector2) -> bool:
    if path_points.size() < 2: # Si hay menos de 2 puntos, no hay problema
        return false

    # Comprobar contra todos los puntos excepto el último (que es current_pos antes del nuevo movimiento)
    for i in range(path_points.size() - 1):
        var p = path_points[i]
        # Considerar "demasiado cerca" si es el mismo punto o adyacente (distancia Manhattan <= 1)
        # excepto para el punto de origen del segmento actual.
        if p == pos : # El camino no puede volver sobre sí mismo exactamente
            return true
    return false

# Clase auxiliar para ordenar los movimientos potenciales
# Es necesario definirla fuera si GDScript no soporta clases anidadas directamente
# o usar un callable con `funcref`. Por simplicidad, este es un placeholder conceptual.
# En GDScript real, esto se haría con un objeto que tenga un método de comparación
# o usando `sort_custom` con un `FuncRef` a una función estática o de instancia.
# Esta parte requerirá una implementación más detallada de la lógica de ordenamiento.
# Por ahora, el sort_custom no funcionará como está escrito.
# Lo ideal sería un algoritmo como A* o Dijkstra para encontrar el camino.
# Este generador actual es un random walk dirigido.

# Placeholder para la lógica de ordenación (requiere un objeto Comparer)
# class SortByDirection:
# func compare_directions(a, b, target_dir):
# var da = a.dot(target_dir)
# var db = b.dot(target_dir)
# return da > db # Queremos que los que más se alinean vayan primero

func get_path_points():
    return path_points

func _ready():
    # Ejemplo de uso (se puede quitar o mover a una escena de prueba)
    # generate_path()
    # for point in path_points:
    # print(point)
    pass
