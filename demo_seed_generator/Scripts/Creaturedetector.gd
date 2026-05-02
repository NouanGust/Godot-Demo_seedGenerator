extends Node
class_name CreatureDetectorSimple

## Versão simplificada - mostra criatura mais próxima
## Use esta versão se o raycast não estiver funcionando

@export var detection_range: float = 5.0
@export var update_interval: float = 0.2  # Atualiza a cada 0.2s

var player: Node3D
var ui: CreatureInfoUI
var current_creature: Creature = null
var ui_layer: CanvasLayer
var update_timer: float = 0.0

func _ready() -> void:
	# Aguarda um frame
	await get_tree().process_frame
	
	# Busca player
	player = get_parent()
	
	if not player:
		push_error("Player não encontrado! CreatureDetector deve ser filho do Player")
		return
	
	print("Player encontrado: ", player.get_path())
	
	# Cria CanvasLayer para UI
	ui_layer = CanvasLayer.new()
	ui_layer.layer = 100
	get_tree().root.add_child(ui_layer)
	
	# Cria UI
	ui = CreatureInfoUI.new()
	ui_layer.add_child(ui)
	
	print("CreatureDetectorSimple inicializado!")
	print("Alcance de detecção: ", detection_range, "m")

func _process(delta: float) -> void:
	if not player or not ui:
		return
	
	# Throttle de atualização para performance
	update_timer -= delta
	if update_timer > 0:
		return
	update_timer = update_interval
	
	_find_nearest_creature()

## Encontra a criatura mais próxima
func _find_nearest_creature() -> void:
	var all_creatures = get_tree().get_nodes_in_group("creatures")
	
	# Se não há criaturas no grupo, tenta buscar por tipo
	if all_creatures.is_empty():
		all_creatures = _find_all_creatures()
	
	if all_creatures.is_empty():
		if current_creature:
			current_creature = null
			ui.hide_info()
		return
	
	var nearest_creature: Creature = null
	var nearest_distance: float = detection_range
	
	for node in all_creatures:
		if node is Creature:
			var creature = node as Creature
			var distance = player.global_position.distance_to(creature.global_position)
			
			if distance < nearest_distance:
				nearest_distance = distance
				nearest_creature = creature
	
	# Atualiza UI
	if nearest_creature != current_creature:
		current_creature = nearest_creature
		
		if current_creature:
			ui.show_creature_info(current_creature)
			print("Criatura próxima: ", current_creature.name, " (", "%.2f" % nearest_distance, "m)")
		else:
			ui.hide_info()

## Busca todas as criaturas na cena
func _find_all_creatures() -> Array:
	var creatures = []
	_search_creatures_recursive(get_tree().root, creatures)
	
	# Adiciona ao grupo para próximas buscas
	for creature in creatures:
		if not creature.is_in_group("creatures"):
			creature.add_to_group("creatures")
	
	if not creatures.is_empty():
		print("🔍 Encontradas ", creatures.size(), " criaturas na cena")
	
	return creatures

## Busca recursiva de criaturas
func _search_creatures_recursive(node: Node, result: Array) -> void:
	if node is Creature:
		result.append(node)
	
	for child in node.get_children():
		_search_creatures_recursive(child, result)

## Debug: Mostra info de todas as criaturas
func print_all_creatures() -> void:
	var creatures = _find_all_creatures()
	print("\n=== CRIATURAS DETECTADAS ===")
	print("Total: ", creatures.size())
	for creature in creatures:
		if creature is Creature:
			var dist = player.global_position.distance_to(creature.global_position)
			print("  - ", creature.name, " (", "%.2f" % dist, "m)")

func _input(event: InputEvent) -> void:
	# Page Up para debug
	if event.is_action_pressed("ui_page_up"):
		print_all_creatures()
	
	# End para toggle UI manualmente
	if event.is_action_pressed("ui_end"):
		if ui.visible:
			ui.hide_info()
		else:
			_find_nearest_creature()
