extends CharacterBody3D
class_name Creature

@export var move_radius: float = 5.0
@export var move_speed: float = 2.0
@export var idle_time: float = 2.0
@export var gravity: float = 9.8  

var start_position: Vector3
var target_position: Vector3
var is_moving: bool = false
var idle_timer: float = 0.0
var vertical_velocity: float = 0.0 

@onready var animation_player: AnimationPlayer = get_node(str(get_tree()) + "AnimationPlayer")

func _ready():
	start_position = global_position
	print(get_node(str(get_tree()) + "AnimationPlayer"))
	_pick_new_target()

func _physics_process(delta):
	_apply_gravity(delta)

	if is_moving:
		_move_towards_target(delta)
	else:
		idle_timer -= delta
		if idle_timer <= 0:
			_pick_new_target()

	move_and_slide()

func _apply_gravity(delta):
	if not is_on_floor():
		vertical_velocity -= gravity * delta
	else:
		vertical_velocity = 0.0

	velocity.y = vertical_velocity

func _move_towards_target(delta):
	var direction = target_position - global_position
	direction.y = 0 

	if direction.length() < 0.2:
		_stop_moving()
		return

	direction = direction.normalized()
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed
	
	look_at(global_position - direction, Vector3.UP)
	animation_player.play("walk")

func _stop_moving():
	is_moving = false
	velocity.x = 0
	velocity.z = 0
	animation_player.play("idle")
	idle_timer = randf_range(idle_time * 0.5, idle_time * 1.5)

func _pick_new_target():
	var random_offset = Vector3(
		randf_range(-move_radius, move_radius),
		0,
		randf_range(-move_radius, move_radius)
	)
	target_position = start_position + random_offset
	is_moving = true
extends CharacterBody3D
class_name Creature

@export var move_radius: float = 5.0
@export var move_speed: float = 2.0
@export var idle_time: float = 2.0
@export var gravity: float = 9.8
@export var personal_space: float = 1.0  # Distância mínima entre criaturas
@export var avoidance_strength: float = 2.0  # Força de repulsão

var start_position: Vector3
var target_position: Vector3
var is_moving: bool = false
var idle_timer: float = 0.0
var vertical_velocity: float = 0.0 

var animation_player: AnimationPlayer

# Sistema de variantes
var creature_seed: int = 0
var is_shiny: bool = false
var creature_variant: CreatureVariant
var shiny_effects: ShinyEffects
var creature_stats: Dictionary = {}

# Sistema de área pessoal
var nearby_creatures: Array[Creature] = []

func _ready():
	add_to_group("creatures")  # Adiciona ao grupo para detecção
	start_position = global_position
	_find_animation_player()
	_pick_new_target()

func _find_animation_player():
	# Busca o AnimationPlayer na hierarquia da criatura
	# Funciona para bee_bot e beetle_bot_fused
	for child in get_children():
		var anim_player = child.find_child("AnimationPlayer", true, false)
		if anim_player and anim_player is AnimationPlayer:
			animation_player = anim_player
			print("AnimationPlayer encontrado em: ", anim_player.get_path())
			return
	
	push_warning("AnimationPlayer não encontrado para: " + name)

## Define dados da criatura (chamado pelo SpawnController)
func set_creature_data(seed: int, shiny: bool, stats: Dictionary) -> void:
	creature_seed = seed
	is_shiny = shiny
	creature_stats = stats
	
	# Aplica stats aos parâmetros da criatura
	if stats.has("speed"):
		move_speed = stats.speed
	
	# Cria e aplica variante visual
	_apply_variant()
	
	# Adiciona efeitos shiny se necessário
	if is_shiny:
		_add_shiny_effects()
	
	# Log
	var shiny_text = "✨ SHINY" if is_shiny else "Normal"
	print("🦋 Criatura configurada: ", name, " [", shiny_text, "] Seed: ", creature_seed)

## Aplica variante visual
func _apply_variant() -> void:
	# Cria variante apropriada
	creature_variant = CreatureVariant.create_variant_for_creature(name, is_shiny, creature_seed)
	
	# Aplica ao modelo 3D
	creature_variant.apply_to_node(self)
	
	if is_shiny:
		print("  ✨ Variante shiny aplicada!")

## Adiciona efeitos visuais shiny
func _add_shiny_effects() -> void:
	# Identifica tipo de criatura
	var name_lower = name.to_lower()
	
	if "abelha" in name_lower or "bee" in name_lower:
		shiny_effects = ShinyEffects.create_for_abelha_shiny(self)
	elif "besouro" in name_lower or "beetle" in name_lower:
		shiny_effects = ShinyEffects.create_for_besouro_shiny(self)
	else:
		var effect_color = creature_variant.emission_color if creature_variant else Color.GOLD
		shiny_effects = ShinyEffects.create_generic_shiny(self, effect_color)
	
	# Efeito de spawn especial
	if shiny_effects:
		shiny_effects.play_spawn_effect()

## Retorna se a criatura é shiny
func get_is_shiny() -> bool:
	return is_shiny

## Retorna seed da criatura
func get_creature_seed() -> int:
	return creature_seed

## Retorna stats da criatura
func get_stats() -> Dictionary:
	return creature_stats

## Debug: Imprime informações da criatura
func print_creature_info() -> void:
	print("\n=== CRIATURA: ", name, " ===")
	print("Seed: ", creature_seed)
	print("Shiny: ", "SIM ✨" if is_shiny else "NÃO")
	print("Stats: ", creature_stats)
	if creature_variant:
		creature_variant.print_info()

func _physics_process(delta):
	_apply_gravity(delta)
	
	# Detecta criaturas próximas para evitar colisões
	_update_nearby_creatures()

	if is_moving:
		_move_towards_target(delta)
	else:
		idle_timer -= delta
		if idle_timer <= 0:
			_pick_new_target()
	
	# Aplica força de repulsão de outras criaturas
	_apply_avoidance()

	move_and_slide()

## Atualiza lista de criaturas próximas
func _update_nearby_creatures() -> void:
	nearby_creatures.clear()
	
	var all_creatures = get_tree().get_nodes_in_group("creatures")
	
	for creature in all_creatures:
		if creature == self or not creature is Creature:
			continue
		
		var distance = global_position.distance_to(creature.global_position)
		
		# Se está dentro do espaço pessoal
		if distance < personal_space:
			nearby_creatures.append(creature)

## Aplica força de repulsão para manter espaço pessoal
func _apply_avoidance() -> void:
	if nearby_creatures.is_empty():
		return
	
	var avoidance_vector = Vector3.ZERO
	
	for creature in nearby_creatures:
		if not is_instance_valid(creature):
			continue
		
		# Vetor de repulsão (afasta da outra criatura)
		var direction_away = global_position - creature.global_position
		direction_away.y = 0  # Mantém no plano horizontal
		
		if direction_away.length() > 0:
			# Força inversamente proporcional à distância
			var distance = direction_away.length()
			var repulsion_strength = (personal_space - distance) / personal_space
			repulsion_strength = clamp(repulsion_strength, 0.0, 1.0)
			
			avoidance_vector += direction_away.normalized() * repulsion_strength * avoidance_strength
	
	# Aplica força de repulsão à velocidade
	if avoidance_vector.length() > 0:
		velocity.x += avoidance_vector.x
		velocity.z += avoidance_vector.z
		
		# Limita velocidade máxima
		var horizontal_vel = Vector2(velocity.x, velocity.z)
		if horizontal_vel.length() > move_speed * 1.5:  # 150% da velocidade normal
			horizontal_vel = horizontal_vel.normalized() * move_speed * 1.5
			velocity.x = horizontal_vel.x
			velocity.z = horizontal_vel.y

func _apply_gravity(delta):
	if not is_on_floor():
		vertical_velocity -= gravity * delta
	else:
		vertical_velocity = 0.0

	velocity.y = vertical_velocity

func _move_towards_target(delta):
	var direction = target_position - global_position
	direction.y = 0 

	if direction.length() < 0.2:
		_stop_moving()
		return

	direction = direction.normalized()
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed
	
	look_at(global_position - direction, Vector3.UP)
	
	if animation_player:
		# Tenta diferentes variações do nome da animação
		if animation_player.has_animation("walk"):
			animation_player.play("walk")
		elif animation_player.has_animation("Walk"):
			animation_player.play("Walk")

func _stop_moving():
	is_moving = false
	velocity.x = 0
	velocity.z = 0
	
	if animation_player:
		# Tenta diferentes variações do nome da animação
		if animation_player.has_animation("idle"):
			animation_player.play("idle")
		elif animation_player.has_animation("Idle"):
			animation_player.play("Idle")
	
	idle_timer = randf_range(idle_time * 0.5, idle_time * 1.5)

func _pick_new_target():
	var random_offset = Vector3(
		randf_range(-move_radius, move_radius),
		0,
		randf_range(-move_radius, move_radius)
	)
	target_position = start_position + random_offset
	is_moving = true
