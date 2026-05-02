extends Node
class_name SeedGenerator

## Sistema de geração e manipulação de seeds
## Garante reprodutibilidade: mesma seed = mesmos resultados

# Seed atual do mundo
var current_seed: int = 0

# RNG determinístico
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _init():
	pass

## Gera uma nova seed baseada no timestamp atual
func generate_new_seed() -> int:
	var timestamp = Time.get_ticks_msec()
	var random_component = randi()
	current_seed = hash(str(timestamp) + str(random_component))
	return abs(current_seed)

## Define uma seed específica para reprodutibilidade
func set_seed(seed_value: int) -> void:
	current_seed = abs(seed_value)
	rng.seed = current_seed
	print("Seed definida: ", current_seed)

## Obtém a seed atual
func get_current_seed() -> int:
	return current_seed

## Gera um número inteiro aleatório entre min e max (inclusivo)
func random_int(min_val: int, max_val: int) -> int:
	return rng.randi_range(min_val, max_val)

## Gera um número float aleatório entre min e max
func random_float(min_val: float, max_val: float) -> float:
	return rng.randf_range(min_val, max_val)

## Gera um booleano aleatório com probabilidade especificada
func random_bool(probability: float = 0.5) -> bool:
	return rng.randf() < probability

## Escolhe um elemento aleatório de um array
func random_choice(array: Array):
	if array.is_empty():
		return null
	return array[rng.randi_range(0, array.size() - 1)]

## Gera uma seed única para uma criatura específica baseada em posição e índice
func generate_creature_seed(world_seed: int, zone_index: int, creature_index: int) -> int:
	var combined = str(world_seed) + "_" + str(zone_index) + "_" + str(creature_index)
	return abs(hash(combined))

## Converte seed em hash para segurança/ofuscação
func seed_to_hash(seed_value: int) -> String:
	return str(hash(str(seed_value))).md5_text()

## Converte hash de volta para seed
func hash_to_seed(hash_string: String) -> int:
	return abs(hash(hash_string))

## Cria um novo RNG temporário com seed específica (útil para cálculos isolados)
func create_temp_rng(seed_value: int) -> RandomNumberGenerator:
	var temp_rng = RandomNumberGenerator.new()
	temp_rng.seed = abs(seed_value)
	return temp_rng

## Verifica se uma criatura deve ser shiny baseado na seed
## Probabilidade padrão: 1/4096 (como Pokémon) -- 0.5 == 50% de chance.
func is_shiny(creature_seed: int, shiny_chance: float = 0.5) -> bool:
	var temp_rng = create_temp_rng(creature_seed)
	return temp_rng.randf() < shiny_chance

## Gera stats aleatórios para uma criatura baseado na seed
func generate_creature_stats(creature_seed: int) -> Dictionary:
	var temp_rng = create_temp_rng(creature_seed)
	
	return {
		"hp": temp_rng.randi_range(50, 150),
		"speed": temp_rng.randf_range(1.0, 5.0),
		"size_scale": temp_rng.randf_range(0.8, 1.2),
		"aggression": temp_rng.randf_range(0.0, 1.0),
		"rarity": temp_rng.randf_range(0.0, 1.0)
	}

## Debug: Testa reprodutibilidade da seed
func test_reproducibility(test_seed: int, iterations: int = 10) -> void:
	print("\n=== TESTE DE REPRODUTIBILIDADE ===")
	print("Seed de teste: ", test_seed)
	print("\nPrimeira execução:")
	
	set_seed(test_seed)
	var first_run = []
	for i in range(iterations):
		first_run.append(random_int(1, 100))
	print(first_run)
	
	print("\nSegunda execução (mesma seed):")
	set_seed(test_seed)
	var second_run = []
	for i in range(iterations):
		second_run.append(random_int(1, 100))
	print(second_run)
	
	var match = first_run == second_run
	print("\nResultados idênticos: ", match)
	if match:
		print("✅ Reprodutibilidade confirmada!")
	else:
		print("❌ Erro: Resultados diferentes!")
