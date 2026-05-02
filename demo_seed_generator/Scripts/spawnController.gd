extends Node3D

@export var creatures: Array[PackedScene]
@export var spwan_zones: Array[Area3D]
@export var max_creatures: int = 10

var spawned_creatures: Array[Node3D] = []

func _ready() -> void:
	spawn_creatures()

func spawn_creatures():
	for i in range(max_creatures):
		var zone = spwan_zones.pick_random()
		var creature_scene = creatures.pick_random()
		
		var creature_instance = creature_scene.instantiate()
		var spawn_position = get_random_position_in_zone(zone)
		creature_instance.global_transform.origin = spawn_position
		add_child(creature_instance)
		spawned_creatures.append(creature_instance)
		

func get_random_position_in_zone(zone: Area3D):
	var shape = zone.get_node("CollisionShape3D").shape
	if shape is BoxShape3D:
		var extents = shape.extents
		var random_offset = Vector3(randf_range(-extents.x, extents.x), randf_range(-extents.y, extents.y), randf_range(-extents.z, extents.z))
		return zone.global_transform.origin + random_offset
	else:
		push_warning("Forma de spawn não suportada para " + zone.name)
		return zone.global_transform.origin 
extends Node3D
class_name SpawnController

## Controlador de spawn baseado em seeds
## Garante spawns determinísticos e reprodutíveis

@export var creatures: Array[PackedScene]
@export var spawn_zones: Array[Area3D]
@export var max_creatures: int = 10
@export var use_seed_system: bool = true  # Toggle para sistema de seeds
@export var custom_seed: int = 0  # Seed customizada (0 = gera automaticamente)

# Biomas por zona
var biome_data_by_zone: Dictionary = {}

# Sistema de seeds
var seed_generator: SeedGenerator
var spawned_creatures: Array[Node3D] = []

# Dados de spawn para debug/save
var spawn_info: Array[Dictionary] = []

func _ready() -> void:
	_initialize_seed_system()
	_initialize_biomes()
	
	# Aguarda um frame para garantir que tudo está na árvore
	await get_tree().process_frame
	spawn_creatures()

## Inicializa o sistema de seeds
func _initialize_seed_system() -> void:
	seed_generator = SeedGenerator.new()
	
	if use_seed_system:
		if custom_seed > 0:
			seed_generator.set_seed(custom_seed)
			print("🎲 Usando seed customizada: ", custom_seed)
		else:
			var new_seed = seed_generator.generate_new_seed()
			seed_generator.set_seed(new_seed)
			print("🎲 Seed gerada automaticamente: ", new_seed)
	else:
		print("⚠️ Sistema de seeds desabilitado - spawns aleatórios")

## Inicializa dados de bioma para cada zona
func _initialize_biomes() -> void:
	if spawn_zones.is_empty():
		return
	
	# Mapeamento de zonas para biomas
	for zone in spawn_zones:
		var biome: BiomeData
		
		# Identifica bioma pelo nome da zona
		if "lago" in zone.name.to_lower():
			biome = BiomeData.create_lago_biome()
		elif "floresta" in zone.name.to_lower():
			biome = BiomeData.create_floresta_biome()
		elif "montanha" in zone.name.to_lower():
			biome = BiomeData.create_montanha_biome()
		elif "cidade" in zone.name.to_lower():
			biome = BiomeData.create_cidade_biome()
		else:
			# Bioma padrão
			biome = BiomeData.create_floresta_biome()
		
		biome_data_by_zone[zone] = biome
		print("Zona '", zone.name, "' configurada como bioma: ", biome.biome_name)

## Spawn principal de criaturas
func spawn_creatures():
	if spawn_zones.is_empty():
		push_error("Nenhuma zona de spawn configurada!")
		return
	
	if creatures.is_empty():
		push_error("Nenhuma criatura configurada para spawn!")
		return
	
	print("\nIniciando spawn de criaturas...")
	print("Seed do mundo: ", seed_generator.get_current_seed())
	print("Total de zonas: ", spawn_zones.size())
	
	spawn_info.clear()
	var total_spawned = 0
	
	# Spawn por zona
	for zone_index in range(spawn_zones.size()):
		var zone = spawn_zones[zone_index]
		var biome = biome_data_by_zone.get(zone)
		
		if not biome:
			continue
		
		# Determina quantas criaturas spawnar nesta zona
		var creatures_in_zone = biome.get_spawn_count(seed_generator.rng)
		
		# Limita ao máximo global
		var remaining = max_creatures - total_spawned
		creatures_in_zone = min(creatures_in_zone, remaining)
		
		if creatures_in_zone <= 0:
			continue
		
		print("\nZona: ", zone.name, " (", biome.biome_name, ")")
		print("  Spawning: ", creatures_in_zone, " criaturas")
		
		# Spawn criaturas na zona
		for i in range(creatures_in_zone):
			_spawn_single_creature(zone, zone_index, i, biome)
			total_spawned += 1
			
			if total_spawned >= max_creatures:
				break
		
		if total_spawned >= max_creatures:
			break
	
	print("\nSpawn completo: ", total_spawned, " criaturas spawned")

## Spawn de uma única criatura
func _spawn_single_creature(zone: Area3D, zone_index: int, creature_index: int, biome: BiomeData) -> void:
	# Gera seed única para esta criatura
	var creature_seed = seed_generator.generate_creature_seed(
		seed_generator.get_current_seed(),
		zone_index,
		creature_index
	)
	
	# Seleciona criatura baseada na tabela de encontros do bioma
	var encounter_data = biome.get_random_creature(seed_generator.rng)
	var creature_path = encounter_data.get("creature_path", "")
	
	# Carrega a cena da criatura
	var creature_scene = load(creature_path) as PackedScene
	if not creature_scene:
		push_warning("Falha ao carregar criatura: ", creature_path)
		return
	
	# Instancia criatura
	var creature_instance = creature_scene.instantiate() as CharacterBody3D
	if not creature_instance:
		return
	
	# Define posição de spawn
	var spawn_position = get_random_position_in_zone(zone)
	
	# Determina se é shiny
	var shiny_chance = biome.get_shiny_chance()
	var is_shiny = seed_generator.is_shiny(creature_seed, shiny_chance)
	
	# Gera stats baseados na seed
	var stats = seed_generator.generate_creature_stats(creature_seed)
	
	# Define nome descritivo da criatura
	var creature_type = creature_path.get_file().get_basename().capitalize()
	var creature_number = creature_index + 1
	var shiny_marker = "✨" if is_shiny else ""
	creature_instance.name = creature_type + "_" + str(creature_number) + shiny_marker
	
	# Adiciona à cena
	add_child(creature_instance)
	creature_instance.global_position = spawn_position
	
	# Aplica stats se a criatura tiver suporte
	if creature_instance.has_method("set_creature_data"):
		creature_instance.set_creature_data(creature_seed, is_shiny, stats)
	
	# Registra informações
	spawned_creatures.append(creature_instance)
	
	var info = {
		"name": creature_instance.name,
		"seed": creature_seed,
		"is_shiny": is_shiny,
		"zone": zone.name,
		"biome": biome.biome_name,
		"position": spawn_position,
		"stats": stats,
		"rarity": encounter_data.get("rarity", "comum")
	}
	spawn_info.append(info)
	
	# Log
	var shiny_icon = "✨" if is_shiny else "  "
	var creature_name = creature_path.get_file().get_basename()
	print("    ", shiny_icon, creature_name, " [Seed: ", creature_seed, "]")

## Obtém posição aleatória dentro da zona
func get_random_position_in_zone(zone: Area3D) -> Vector3:
	var collision_shape = zone.get_node("CollisionShape3D")
	if not collision_shape:
		push_warning("CollisionShape3D não encontrado em " + zone.name)
		return zone.global_position
	
	var shape = collision_shape.shape
	
	if shape is BoxShape3D:
		var half_size = shape.size / 2.0
		var random_offset = Vector3(
			seed_generator.random_float(-half_size.x, half_size.x),
			seed_generator.random_float(-half_size.y, half_size.y),
			seed_generator.random_float(-half_size.z, half_size.z)
		)
		return zone.global_position + random_offset
	else:
		push_warning("Forma de spawn não suportada para " + zone.name)
		return zone.global_position

## Limpa todas as criaturas spawned
func clear_creatures() -> void:
	for creature in spawned_creatures:
		if is_instance_valid(creature):
			creature.queue_free()
	spawned_creatures.clear()
	spawn_info.clear()
	print("Todas as criaturas removidas")

## Re-spawn com nova seed
func respawn_with_new_seed(new_seed: int = 0) -> void:
	clear_creatures()
	
	if new_seed > 0:
		seed_generator.set_seed(new_seed)
	else:
		var generated_seed = seed_generator.generate_new_seed()
		seed_generator.set_seed(generated_seed)
	
	await get_tree().process_frame
	spawn_creatures()

## Re-spawn com a mesma seed (teste de reprodutibilidade)
func respawn_same_seed() -> void:
	var current = seed_generator.get_current_seed()
	clear_creatures()
	seed_generator.set_seed(current)
	await get_tree().process_frame
	spawn_creatures()

## Debug: Imprime informações de todas as criaturas spawned
func print_spawn_info() -> void:
	print("\n=== INFORMAÇÕES DE SPAWN ===")
	print("Seed do mundo: ", seed_generator.get_current_seed())
	print("Total de criaturas: ", spawn_info.size())
	
	for info in spawn_info:
		print("\n---")
		print("Nome: ", info.name)
		print("Seed: ", info.seed)
		print("Shiny: ", "SIM" if info.is_shiny else "NÃO")
		print("Zona: ", info.zone, " (", info.biome, ")")
		print("Raridade: ", info.rarity)
		print("Stats: ", info.stats)
