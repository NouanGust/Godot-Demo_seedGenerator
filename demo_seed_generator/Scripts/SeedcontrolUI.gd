extends Control
class_name SeedControlUI

## UI de controle de seeds
## Permite resetar seed e ver seed atual

# Nodes da UI
var panel: PanelContainer
var vbox: VBoxContainer
var seed_display_label: Label
var reset_button: Button
var new_seed_button: Button
var input_line: LineEdit
var set_seed_button: Button

# Referência ao spawn controller
var spawn_controller: SpawnController

signal seed_reset_requested
signal new_seed_requested
signal custom_seed_requested(seed_value: int)

func _ready() -> void:
	_create_ui()
	_find_spawn_controller()

## Cria interface
func _create_ui() -> void:
	# Posicionamento no canto superior direito
	set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	
	# Panel container
	panel = PanelContainer.new()
	add_child(panel)
	
	# Posição e tamanho
	panel.position = Vector2(-320, 20)
	panel.custom_minimum_size = Vector2(300, 180)
	
	# Estilo do painel
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.2, 0.9)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.3, 0.5, 0.7, 1.0)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	panel.add_theme_stylebox_override("panel", style)
	
	# Margin
	var margin = MarginContainer.new()
	panel.add_child(margin)
	margin.add_theme_constant_override("margin_left", 15)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_top", 15)
	margin.add_theme_constant_override("margin_bottom", 15)
	
	# VBox
	vbox = VBoxContainer.new()
	margin.add_child(vbox)
	vbox.add_theme_constant_override("separation", 10)
	
	# Título
	var title_label = Label.new()
	title_label.text = "🎲 Seed Control"
	title_label.add_theme_font_size_override("font_size", 18)
	title_label.add_theme_color_override("font_color", Color(0.7, 0.9, 1.0))
	vbox.add_child(title_label)
	
	# Separador
	var separator1 = HSeparator.new()
	vbox.add_child(separator1)
	
	# Display da seed atual
	seed_display_label = Label.new()
	seed_display_label.text = "Seed: Carregando..."
	seed_display_label.add_theme_font_size_override("font_size", 12)
	seed_display_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
	vbox.add_child(seed_display_label)
	
	# Botão Reset (mesma seed)
	reset_button = Button.new()
	reset_button.text = "🔄 Reset (mesma seed)"
	reset_button.custom_minimum_size = Vector2(0, 35)
	vbox.add_child(reset_button)
	reset_button.pressed.connect(_on_reset_pressed)
	
	# Botão Nova Seed
	new_seed_button = Button.new()
	new_seed_button.text = "🎲 Nova Seed Aleatória"
	new_seed_button.custom_minimum_size = Vector2(0, 35)
	vbox.add_child(new_seed_button)
	new_seed_button.pressed.connect(_on_new_seed_pressed)
	
	# Separador
	var separator2 = HSeparator.new()
	vbox.add_child(separator2)
	
	# Input de seed customizada
	var hbox = HBoxContainer.new()
	vbox.add_child(hbox)
	
	input_line = LineEdit.new()
	input_line.placeholder_text = "Seed customizada"
	input_line.custom_minimum_size = Vector2(150, 30)
	hbox.add_child(input_line)
	
	set_seed_button = Button.new()
	set_seed_button.text = "✓"
	set_seed_button.custom_minimum_size = Vector2(40, 30)
	hbox.add_child(set_seed_button)
	set_seed_button.pressed.connect(_on_set_seed_pressed)
	
	print("✅ SeedControlUI criada!")

## Busca o SpawnController na cena
func _find_spawn_controller() -> void:
	# Busca no World
	var world = get_tree().root.get_node_or_null("World")
	if world:
		spawn_controller = world.get_node_or_null("Spawn_zones")
	
	if spawn_controller:
		print("✅ SpawnController encontrado!")
		_update_seed_display()
	else:
		push_warning("⚠️ SpawnController não encontrado!")

## Atualiza display da seed atual
func _update_seed_display() -> void:
	if spawn_controller and spawn_controller.seed_generator:
		var current_seed = spawn_controller.seed_generator.get_current_seed()
		seed_display_label.text = "Seed: " + str(current_seed)

## Callback do botão Reset
func _on_reset_pressed() -> void:
	if spawn_controller:
		print("🔄 Resetando com mesma seed...")
		spawn_controller.respawn_same_seed()
		_update_seed_display()
	else:
		print("❌ SpawnController não encontrado!")

## Callback do botão Nova Seed
func _on_new_seed_pressed() -> void:
	if spawn_controller:
		print("🎲 Gerando nova seed...")
		spawn_controller.respawn_with_new_seed()
		_update_seed_display()
	else:
		print("❌ SpawnController não encontrado!")

## Callback do botão Set Seed
func _on_set_seed_pressed() -> void:
	var input_text = input_line.text.strip_edges()
	
	if input_text.is_empty():
		print("⚠️ Digite uma seed primeiro!")
		return
	
	if not input_text.is_valid_int():
		print("❌ Seed inválida! Use apenas números.")
		return
	
	var custom_seed = input_text.to_int()
	
	if spawn_controller:
		print("✨ Aplicando seed customizada: ", custom_seed)
		spawn_controller.respawn_with_new_seed(custom_seed)
		_update_seed_display()
		input_line.clear()
	else:
		print("❌ SpawnController não encontrado!")

## Atualiza UI periodicamente
func _process(_delta: float) -> void:
	# Atualiza seed display a cada frame (leve)
	if spawn_controller and spawn_controller.seed_generator:
		var current_seed = spawn_controller.seed_generator.get_current_seed()
		var display_text = "Seed: " + str(current_seed)
		
		if seed_display_label.text != display_text:
			seed_display_label.text = display_text
