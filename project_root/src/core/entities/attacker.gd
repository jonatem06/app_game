# src/core/entities/attacker.gd
extends GameEntity
class_name Attacker

signal attacker_reached_end(attacker_node)
signal attacker_died_give_reward(gold_amount)

var movement_speed: float = 50.0
var base_movement_speed: float = 50.0 # Para restaurar después de efectos de velocidad
var path_points: Array = []
var current_path_index: int = 0
var gold_reward: int = 0

# --- Variables para Estados Elementales ---
# Quemadura
var is_burning: bool = false
var burn_damage_dps: float = 0.0 # Daño por segundo
var burn_duration: float = 0.0
var burn_timer: float = 0.0

# Congelación (Slow)
var is_slowed: bool = false
var slow_factor: float = 1.0 # 1.0 = sin slow, 0.5 = 50% slow
var slow_duration: float = 0.0
var slow_timer: float = 0.0

# Retroceso (Pushback) - es instantáneo, no necesita duración aquí
# pero podríamos añadir un breve cooldown para no ser empujado constantemente.
var last_pushback_time: float = 0.0
const PUSHBACK_COOLDOWN: float = 0.5 # Medio segundo entre empujones


func _init(start_health: float, speed: float, reward: int):
	super._init(start_health)
	self.base_movement_speed = speed
	self.movement_speed = speed
	self.gold_reward = reward

func set_path(new_path: Array):
	self.path_points = new_path
	self.current_path_index = 0
	if not path_points.empty():
		set_position(path_points[0])

func _physics_process(delta: float):
	if is_dead:
		return

	# Actualizar estados elementales
	update_burn_effect(delta)
	update_slow_effect(delta)

	if path_points.empty() or current_path_index >= path_points.size():
		return

	var target_point = path_points[current_path_index]
	var direction = (target_point - get_position()).normalized()
	var distance_to_target = get_position().distance_to(target_point)

	var current_move_delta = movement_speed * delta
	if distance_to_target < current_move_delta:
		set_position(target_point)
		current_path_index += 1
		if current_path_index >= path_points.size():
			reach_end_of_path()
	else:
		translate(direction * current_move_delta)

func reach_end_of_path():
	print(self.name + " reached the end of the path.")
	emit_signal("attacker_reached_end", self)
	is_dead = true
	if not is_queued_for_deletion():
		queue_free()

func die():
	super.die()
	if gold_reward > 0:
		emit_signal("attacker_died_give_reward", gold_reward)
	if not is_queued_for_deletion():
		queue_free()

# --- Funciones para Estados Elementales ---

# QUEMADURA
func apply_burn(damage_per_second: float, duration: float):
	is_burning = true
	burn_damage_dps = damage_per_second
	burn_duration = duration
	burn_timer = duration
	print(self.name + " is now BURNING for " + str(damage_per_second) + " dps for " + str(duration) + "s.")

func update_burn_effect(delta: float):
	if is_burning:
		if burn_timer > 0:
			burn_timer -= delta
			var damage_this_frame = burn_damage_dps * delta
			take_damage(damage_this_frame) # Aplicar daño de quemadura
			# print(self.name + " took " + str(damage_this_frame) + " burn damage. HP: " + str(health))
			if is_dead: # Si la quemadura lo mata
				is_burning = false # Detener efecto
				return
		else:
			is_burning = false
			burn_damage_dps = 0
			burn_duration = 0
			print(self.name + " is no longer burning.")

# CONGELACIÓN (SLOW)
func apply_slow(factor: float, duration: float):
	if not is_slowed: # Aplicar solo si no está ya ralentizado, o el nuevo es más fuerte/largo
		is_slowed = true
		slow_factor = clamp(factor, 0.1, 1.0) # Asegurar que el factor sea razonable
		movement_speed = base_movement_speed * slow_factor
	# Si ya está ralentizado, podríamos decidir si el nuevo efecto sobreescribe (ej. si es más potente o reinicia duración)
	# Por ahora, simplemente actualizamos la duración si se reaplica.
	slow_duration = duration
	slow_timer = duration
	print(self.name + " is SLOWED by factor " + str(factor) + " for " + str(duration) + "s. New speed: " + str(movement_speed))

func update_slow_effect(delta: float):
	if is_slowed:
		if slow_timer > 0:
			slow_timer -= delta
		else:
			is_slowed = false
			slow_factor = 1.0
			movement_speed = base_movement_speed # Restaurar velocidad base
			print(self.name + " is no longer slowed. Speed restored to " + str(movement_speed))

# RETROCESO (PUSHBACK)
func apply_pushback(distance_pixels: float):
	var current_time = OS.get_ticks_msec() / 1000.0
	if current_time - last_pushback_time < PUSHBACK_COOLDOWN:
		# print(self.name + " is immune to pushback (cooldown).")
		return # Cooldown para evitar ser empujado constantemente

	last_pushback_time = current_time

	if path_points.empty() or current_path_index == 0: # No puede retroceder si está en el inicio o no tiene camino
		print(self.name + " cannot be pushed back (at start or no path).")
		return

	var distance_to_push_back = distance_pixels

	# Retroceder a lo largo del camino
	var pushed_back_target_index = current_path_index
	var pushed_back_position = get_position()

	# Intentar retroceder 'distance_pixels' a lo largo de los segmentos del camino anteriores
	while distance_to_push_back > 0 and pushed_back_target_index > 0:
		var prev_point_on_path = path_points[pushed_back_target_index - 1]
		var current_segment_vector = pushed_back_position - prev_point_on_path
		var current_segment_length = current_segment_vector.length()

		if current_segment_length >= distance_to_push_back:
			# El retroceso termina en este segmento
			pushed_back_position = pushed_back_position - current_segment_vector.normalized() * distance_to_push_back
			distance_to_push_back = 0
		else:
			# El retroceso consume este segmento y continúa al anterior
			pushed_back_position = prev_point_on_path
			distance_to_push_back -= current_segment_length
			pushed_back_target_index -= 1

	# Actualizar posición y el índice del camino actual
	# Es importante que el nuevo current_path_index sea el del punto *al que se dirige*
	# después del retroceso. Si se movió a path_points[pushed_back_target_index-1],
	# entonces el nuevo objetivo es path_points[pushed_back_target_index].

	set_position(pushed_back_position)
	# El nuevo current_path_index debe ser el índice del *siguiente* punto en el camino
	# desde la nueva posición. Si pushed_back_target_index es el índice del punto donde aterrizó,
	# entonces el siguiente es ese mismo índice (ya que current_path_index es el objetivo, no el actual).
	self.current_path_index = pushed_back_target_index

	print(self.name + " was PUSHED BACK. New pos: " + str(get_position()) + ", new path target index: " + str(self.current_path_index))
