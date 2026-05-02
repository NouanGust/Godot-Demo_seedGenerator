extends Resource
class_name CreatureVariant

## Sistema de variantes de criaturas (Normal/Shiny)
## Gerencia cores, materiais e identificação de variantes

enum VariantType {
	NORMAL,
	SHINY,
	RARE,      # Para futuras expansões
	LEGENDARY  # Para futuras expansões
}

# Tipo da variante
@export var variant_type: VariantType = VariantType.NORMAL

# Cores da variante
@export var primary_color: Color = Color.WHITE
@export var secondary_color: Color = Color.WHITE
@export var emission_color: Color = Color.BLACK
@export var emission_strength: float = 0.0

# Propriedades visuais
@export var metallic: float = 0.0
@export var roughness: float = 1.0
@export var has_emission: bool = false

# Multiplicador de escala (para variantes especiais)
@export var scale_multiplier: float = 1.0

## Cria variante normal baseada em uma seed
static func create_normal_variant(creature_seed: int) -> CreatureVariant:
	var variant = CreatureVariant.new()
	variant.variant_type = VariantType.NORMAL
	
	# Usa a seed para gerar variações sutis na cor normal
	var rng = RandomNumberGenerator.new()
	rng.seed = creature_seed
	
	# Variações sutis (95-105% do valor original)
	var variation = rng.randf_range(0.95, 1.05)
	
	# Cores padrão com leve variação
	variant.primary_color = Color.WHITE * variation
	variant.secondary_color = Color.WHITE * variation
	variant.metallic = 0.0
	variant.roughness = rng.randf_range(0.8, 1.0)
	variant.has_emission = false
	
	return variant

## Cria variante shiny para Abelha
static func create_shiny_abelha(creature_seed: int) -> CreatureVariant:
	var variant = CreatureVariant.new()
	variant.variant_type = VariantType.SHINY
	
	# Cores douradas/amarelas brilhantes para abelha shiny
	variant.primary_color = Color(1.0, 0.84, 0.0)  # Dourado
	variant.secondary_color = Color(1.0, 0.95, 0.3)  # Amarelo claro
	variant.emission_color = Color(1.0, 0.9, 0.0)  # Brilho dourado
	variant.emission_strength = 0.5
	variant.metallic = 0.3
	variant.roughness = 0.4
	variant.has_emission = true
	variant.scale_multiplier = 1.1  # 10% maior
	
	return variant

## Cria variante shiny para Besouro
static func create_shiny_besouro(creature_seed: int) -> CreatureVariant:
	var variant = CreatureVariant.new()
	variant.variant_type = VariantType.SHINY
	
	# Cores azul-roxo metálico para besouro shiny
	variant.primary_color = Color(0.3, 0.1, 0.8)  # Roxo escuro
	variant.secondary_color = Color(0.1, 0.5, 1.0)  # Azul brilhante
	variant.emission_color = Color(0.4, 0.2, 1.0)  # Brilho roxo-azul
	variant.emission_strength = 0.6
	variant.metallic = 0.5
	variant.roughness = 0.3
	variant.has_emission = true
	variant.scale_multiplier = 1.15  # 15% maior
	
	return variant

## Determina qual variante criar baseado no tipo de criatura e se é shiny
static func create_variant_for_creature(creature_name: String, is_shiny: bool, creature_seed: int) -> CreatureVariant:
	if not is_shiny:
		return create_normal_variant(creature_seed)
	
	# Identifica tipo de criatura e cria shiny apropriado
	var name_lower = creature_name.to_lower()
	
	if "abelha" in name_lower or "bee" in name_lower:
		return create_shiny_abelha(creature_seed)
	elif "besouro" in name_lower or "beetle" in name_lower:
		return create_shiny_besouro(creature_seed)
	else:
		# Shiny genérico para criaturas desconhecidas
		return create_generic_shiny(creature_seed)

## Cria variante shiny genérica
static func create_generic_shiny(creature_seed: int) -> CreatureVariant:
	var variant = CreatureVariant.new()
	variant.variant_type = VariantType.SHINY
	
	var rng = RandomNumberGenerator.new()
	rng.seed = creature_seed
	
	# Cores aleatórias mas vibrantes
	variant.primary_color = Color(
		rng.randf_range(0.7, 1.0),
		rng.randf_range(0.7, 1.0),
		rng.randf_range(0.7, 1.0)
	)
	variant.secondary_color = Color(
		rng.randf_range(0.5, 1.0),
		rng.randf_range(0.5, 1.0),
		rng.randf_range(0.5, 1.0)
	)
	variant.emission_color = variant.primary_color * 1.2
	variant.emission_strength = 0.4
	variant.metallic = 0.4
	variant.roughness = 0.4
	variant.has_emission = true
	variant.scale_multiplier = 1.1
	
	return variant

## Aplica a variante a um node 3D (modifica materiais)
func apply_to_node(node: Node3D) -> void:
	if not node:
		return
	
	# Aplica escala
	if scale_multiplier != 1.0:
		node.scale *= scale_multiplier
	
	# Busca todos os MeshInstance3D recursivamente
	_apply_to_mesh_recursive(node)

## Aplica cores aos materiais de forma recursiva
func _apply_to_mesh_recursive(node: Node) -> void:
	if node is MeshInstance3D:
		_apply_to_mesh_instance(node)
	
	# Processa filhos
	for child in node.get_children():
		_apply_to_mesh_recursive(child)

## Aplica cores a um MeshInstance3D específico
func _apply_to_mesh_instance(mesh_instance: MeshInstance3D) -> void:
	var mesh = mesh_instance.mesh
	if not mesh:
		return
	
	# Cria novos materiais baseados nos existentes
	for i in range(mesh.get_surface_count()):
		var original_material = mesh.surface_get_material(i)
		
		if original_material is StandardMaterial3D:
			# Duplica o material para não modificar o original
			var new_material = original_material.duplicate() as StandardMaterial3D
			
			# Aplica cores da variante
			new_material.albedo_color = primary_color
			new_material.metallic = metallic
			new_material.roughness = roughness
			
			# Aplica emissão se for shiny
			if has_emission:
				new_material.emission_enabled = true
				new_material.emission = emission_color
				new_material.emission_energy_multiplier = emission_strength
			
			# Aplica o novo material
			mesh_instance.set_surface_override_material(i, new_material)

## Retorna string descritiva da variante
func get_variant_name() -> String:
	match variant_type:
		VariantType.NORMAL:
			return "Normal"
		VariantType.SHINY:
			return "Shiny"
		VariantType.RARE:
			return "Rare"
		VariantType.LEGENDARY:
			return "Legendary"
	return "Unknown"

## Debug: Imprime informações da variante
func print_info() -> void:
	print("=== Variante: ", get_variant_name(), " ===")
	print("Cor Primária: ", primary_color)
	print("Cor Secundária: ", secondary_color)
	if has_emission:
		print("Emissão: ", emission_color, " (força: ", emission_strength, ")")
	print("Metálico: ", metallic)
	print("Rugosidade: ", roughness)
	print("Escala: ", scale_multiplier, "x")
