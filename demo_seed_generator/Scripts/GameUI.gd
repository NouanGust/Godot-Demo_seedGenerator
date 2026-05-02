extends Node

## Autoload para gerenciar UI global do jogo
## Adiciona SeedControlUI automaticamente

var seed_control_ui: SeedControlUI
var ui_layer: CanvasLayer

func _ready() -> void:
	# Aguarda um frame
	await get_tree().process_frame
	
	# Cria CanvasLayer para UIs globais
	ui_layer = CanvasLayer.new()
	ui_layer.layer = 99  # Abaixo do CreatureInfo (100) mas acima do jogo
	ui_layer.name = "GlobalUILayer"
	get_tree().root.add_child(ui_layer)
	
	# Cria UI de controle de seed
	seed_control_ui = SeedControlUI.new()
	ui_layer.add_child(seed_control_ui)
	
	print("✅ GameUI inicializado!")
	print("  - SeedControlUI adicionada")

## Retorna referência à UI de controle de seed
func get_seed_control_ui() -> SeedControlUI:
	return seed_control_ui
