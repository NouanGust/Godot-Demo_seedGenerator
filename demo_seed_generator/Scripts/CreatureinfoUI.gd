extends Control
class_name CreatureInfoUI

## UI para mostrar informações de criaturas
## Aparece quando o jogador olha para uma criatura

# Nodes da UI
var panel: PanelContainer
var vbox: VBoxContainer
var name_label: Label
var seed_label: Label
var variant_label: Label
var stats_label: Label

# Criatura atual sendo exibida
var current_creature: Creature = null

func _ready() -> void:
	_create_ui()
	visible = false  # Começa invisível

## Cria interface
func _create_ui() -> void:
	# Configura como CanvasLayer para ficar sempre no topo
	set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE  # Não captura mouse
	
	# Panel container com estilo
	panel = PanelContainer.new()
	add_child(panel)
	
	# Usa anchors ao invés de offsets fixos
	panel.position = Vector2(20, 20)
	panel.custom_minimum_size = Vector2(300, 200)
	
	# Adiciona um StyleBox para visual melhor
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.85)  # Preto semi-transparente
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.4, 0.4, 0.4, 1.0)  # Borda cinza
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	panel.add_theme_stylebox_override("panel", style)
	
	# MarginContainer para padding interno
	var margin = MarginContainer.new()
	panel.add_child(margin)
	margin.add_theme_constant_override("margin_left", 15)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_top", 15)
	margin.add_theme_constant_override("margin_bottom", 15)
	
	# VBox para organizar labels
	vbox = VBoxContainer.new()
	margin.add_child(vbox)
	vbox.add_theme_constant_override("separation", 8)
	
	# Labels
	name_label = Label.new()
	name_label.add_theme_font_size_override("font_size", 24)
	name_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	vbox.add_child(name_label)
	
	# Separador
	var separator1 = HSeparator.new()
	vbox.add_child(separator1)
	
	variant_label = Label.new()
	variant_label.add_theme_font_size_override("font_size", 20)
	vbox.add_child(variant_label)
	
	seed_label = Label.new()
	seed_label.add_theme_font_size_override("font_size", 14)
	seed_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	vbox.add_child(seed_label)
	
	# Separador
	var separator2 = HSeparator.new()
	vbox.add_child(separator2)
	
	stats_label = Label.new()
	stats_label.add_theme_font_size_override("font_size", 14)
	stats_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	vbox.add_child(stats_label)
	
	print("✅ CreatureInfoUI criada com sucesso!")

## Mostra informações de uma criatura
func show_creature_info(creature: Creature) -> void:
	if not creature:
		hide_info()
		return
	
	current_creature = creature
	
	# Processa nome da criatura para exibição
	var display_name = _format_creature_name(creature.name)
	
	# Atualiza labels
	name_label.text = display_name
	seed_label.text = "Seed: " + str(creature.get_creature_seed())
	
	if creature.get_is_shiny():
		variant_label.text = "✨ SHINY ✨"
		variant_label.add_theme_color_override("font_color", Color.GOLD)
	else:
		variant_label.text = "Normal"
		variant_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
	
	# Stats
	var stats = creature.get_stats()
	var stats_text = "Stats:\n"
	stats_text += "  HP: " + str(stats.get("hp", 0)) + "\n"
	stats_text += "  Speed: " + ("%.2f" % stats.get("speed", 0)) + "\n"
	stats_text += "  Size: " + ("%.2f" % stats.get("size_scale", 1.0)) + "x"
	stats_label.text = stats_text
	
	visible = true
	print("📋 Mostrando info de: ", display_name)

## Formata nome da criatura para exibição mais bonita
func _format_creature_name(creature_name: String) -> String:
	# Remove caractere shiny se presente
	var clean_name = creature_name.replace("✨", "").strip_edges()
	
	# Se tem underscore, separa tipo e número
	if "_" in clean_name:
		var parts = clean_name.split("_")
		var type_name = parts[0]
		var number = parts[1] if parts.size() > 1 else ""
		
		# Adiciona emoji do tipo (opcional)
		var emoji = _get_creature_emoji(type_name)
		
		if creature_name.contains("✨"):
			return emoji + " " + type_name + " #" + number + " ✨"
		else:
			return emoji + " " + type_name + " #" + number
	
	# Se não tem padrão esperado, retorna como está
	return clean_name

## Retorna emoji apropriado para o tipo de criatura
func _get_creature_emoji(type_name: String) -> String:
	var type_lower = type_name.to_lower()
	
	if "abelha" in type_lower or "bee" in type_lower:
		return "🐝"
	elif "besouro" in type_lower or "beetle" in type_lower:
		return "🪲"
	else:
		return "🦋"  # Emoji padrão

## Esconde UI
func hide_info() -> void:
	current_creature = null
	visible = false
	print("🚫 UI escondida")
