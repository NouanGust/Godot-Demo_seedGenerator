extends Resource
class_name BiomeData

## Define dados e tabelas de encontro para cada bioma
## Cada bioma tem suas próprias criaturas, raridades e condições de spawn

enum BiomeType {
	LAGO,      # Bioma aquático
	FLORESTA,  # Bioma florestal
	MONTANHA,  # Bioma montanhoso
	CIDADE     # Bioma urbano
}

# Dados do bioma
@export var biome_name: String = ""
@export var biome_type: BiomeType = BiomeType.FLORESTA
@export var description: String = ""

# Tabela de encontros: [criatura_scene_path, peso_de_spawn]
# Peso maior = maior chance de aparecer
@export var encounter_table: Array = []

# Configurações de spawn
@export var min_creatures: int = 3
@export var max_creatures: int = 8
@export var spawn_radius: float = 8.0

# Modificadores de raridade
@export var shiny_multiplier: float = 1.0  # Multiplicador de chance shiny
@export var rare_creature_boost: float = 1.0  # Boost para criaturas raras

## Cria uma tabela de encontro padrão para o bioma do Lago
static func create_lago_biome() -> BiomeData:
	var biome = BiomeData.new()
	biome.biome_name = "Lago"
	biome.biome_type = BiomeType.LAGO
	biome.description = "Bioma aquático com criaturas adaptadas à água"
	biome.min_creatures = 4
	biome.max_creatures = 8
	biome.shiny_multiplier = 1.2  # 20% mais chance de shiny
	
	# Tabela de encontros do lago
	biome.encounter_table = [
		{
			"creature_path": "res://Scenes/abelha.tscn",
			"weight": 60,  # 60% de chance
			"rarity": "comum"
		},
		{
			"creature_path": "res://Scenes/besouro.tscn",
			"weight": 40,  # 40% de chance
			"rarity": "comum"
		}
	]
	
	return biome

## Cria uma tabela de encontro padrão para o bioma da Floresta
static func create_floresta_biome() -> BiomeData:
	var biome = BiomeData.new()
	biome.biome_name = "Floresta"
	biome.biome_type = BiomeType.FLORESTA
	biome.description = "Bioma florestal com grande diversidade"
	biome.min_creatures = 5
	biome.max_creatures = 10
	biome.shiny_multiplier = 1.0
	
	biome.encounter_table = [
		{
			"creature_path": "res://Scenes/abelha.tscn",
			"weight": 70,  # 70% de chance
			"rarity": "comum"
		},
		{
			"creature_path": "res://Scenes/besouro.tscn",
			"weight": 30,  # 30% de chance
			"rarity": "incomum"
		}
	]
	
	return biome

## Cria uma tabela de encontro padrão para o bioma da Montanha
static func create_montanha_biome() -> BiomeData:
	var biome = BiomeData.new()
	biome.biome_name = "Montanha"
	biome.biome_type = BiomeType.MONTANHA
	biome.description = "Bioma montanhoso com criaturas resistentes"
	biome.min_creatures = 3
	biome.max_creatures = 6
	biome.shiny_multiplier = 0.8  # 20% menos chance de shiny
	biome.rare_creature_boost = 1.5  # Mais criaturas raras
	
	biome.encounter_table = [
		{
			"creature_path": "res://Scenes/besouro.tscn",
			"weight": 65,  # 65% de chance
			"rarity": "comum"
		},
		{
			"creature_path": "res://Scenes/abelha.tscn",
			"weight": 35,  # 35% de chance
			"rarity": "incomum"
		}
	]
	
	return biome

## Cria uma tabela de encontro padrão para o bioma da Cidade
static func create_cidade_biome() -> BiomeData:
	var biome = BiomeData.new()
	biome.biome_name = "Cidade"
	biome.biome_type = BiomeType.CIDADE
	biome.description = "Bioma urbano com criaturas adaptadas"
	biome.min_creatures = 2
	biome.max_creatures = 5
	biome.shiny_multiplier = 1.5  # 50% mais chance de shiny (urbano raro)
	
	biome.encounter_table = [
		{
			"creature_path": "res://Scenes/abelha.tscn",
			"weight": 50,
			"rarity": "comum"
		},
		{
			"creature_path": "res://Scenes/besouro.tscn",
			"weight": 50,
			"rarity": "comum"
		}
	]
	
	return biome

## Seleciona uma criatura aleatória baseada nos pesos da tabela de encontros
func get_random_creature(rng: RandomNumberGenerator) -> Dictionary:
	if encounter_table.is_empty():
		push_error("Tabela de encontros vazia para bioma: " + biome_name)
		return {}
	
	# Calcula peso total
	var total_weight = 0
	for entry in encounter_table:
		total_weight += entry.get("weight", 1)
	
	# Seleciona baseado no peso
	var random_value = rng.randi_range(0, total_weight - 1)
	var current_weight = 0
	
	for entry in encounter_table:
		current_weight += entry.get("weight", 1)
		if random_value < current_weight:
			return entry
	
	# Fallback: retorna primeira criatura
	return encounter_table[0]

## Calcula número de criaturas para spawnar neste bioma
func get_spawn_count(rng: RandomNumberGenerator) -> int:
	return rng.randi_range(min_creatures, max_creatures)

## Retorna a chance de shiny ajustada para este bioma
func get_shiny_chance() -> float:
	var base_chance = 1.0 / 4096.0  # Chance base estilo Pokémon
	return base_chance * shiny_multiplier

## Debug: Imprime informações do bioma
func print_info() -> void:
	print("\n=== BIOMA: ", biome_name, " ===")
	print("Tipo: ", BiomeType.keys()[biome_type])
	print("Descrição: ", description)
	print("Criaturas: ", min_creatures, "-", max_creatures)
	print("Multiplicador Shiny: ", shiny_multiplier, "x")
	print("\nTabela de Encontros:")
	for entry in encounter_table:
		var creature_name = entry.get("creature_path", "").get_file().get_basename()
		print("  - ", creature_name, " (", entry.get("weight", 0), "%) [", entry.get("rarity", "?"), "]")
