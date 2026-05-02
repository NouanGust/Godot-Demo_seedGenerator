extends Node

## Script de teste para o sistema de seeds
## Para usar: Anexe este script a um Node na cena e execute

@onready var spawn_controller: SpawnController = get_node("../Spawn_zones")

func _ready() -> void:
	print("\n" + "=".repeat(50))
	print("INICIANDO TESTES DO SISTEMA DE SEEDS")
	print("=".repeat(50))
	
	# Aguarda spawn inicial
	await get_tree().create_timer(2.0).timeout
	
	if spawn_controller:
		_run_tests()
	else:
		print("SpawnController não encontrado!")

func _run_tests() -> void:
	# Teste 1: Reprodutibilidade básica
	print("\n" + "-".repeat(50))
	print("TESTE 1: Reprodutibilidade Básica")
	print("-".repeat(50))
	_test_reproducibility()
	
	await get_tree().create_timer(2.0).timeout
	
	# Teste 2: Diferentes seeds geram resultados diferentes
	print("\n" + "-".repeat(50))
	print("TESTE 2: Seeds Diferentes")
	print("-".repeat(50))
	_test_different_seeds()
	
	await get_tree().create_timer(2.0).timeout
	
	# Teste 3: Taxa de shiny
	print("\n" + "-".repeat(50))
	print("TESTE 3: Taxa de Shiny")
	print("-".repeat(50))
	_test_shiny_rate()

func _test_reproducibility() -> void:
	print("Testando se a mesma seed gera os mesmos resultados...")
	
	var test_seed = 12345
	
	# Primeira geração
	spawn_controller.respawn_with_new_seed(test_seed)
	await get_tree().create_timer(0.5).timeout
	var first_info = spawn_controller.spawn_info.duplicate(true)
	
	# Segunda geração (mesma seed)
	spawn_controller.respawn_same_seed()
	await get_tree().create_timer(0.5).timeout
	var second_info = spawn_controller.spawn_info.duplicate(true)
	
	# Verifica se são idênticos
	var identical = true
	if first_info.size() != second_info.size():
		identical = false
	else:
		for i in range(first_info.size()):
			if first_info[i].seed != second_info[i].seed:
				identical = false
				break
			if first_info[i].is_shiny != second_info[i].is_shiny:
				identical = false
				break
	
	if identical:
		print("✅ SUCESSO: Mesma seed gerou resultados idênticos!")
		print("   Seed testada: ", test_seed)
		print("   Criaturas spawned: ", first_info.size())
	else:
		print("❌ FALHA: Resultados diferentes com a mesma seed!")

func _test_different_seeds() -> void:
	print("Testando se seeds diferentes geram resultados diferentes...")
	
	# Primeira seed
	spawn_controller.respawn_with_new_seed(11111)
	await get_tree().create_timer(0.5).timeout
	var first_info = spawn_controller.spawn_info.duplicate(true)
	
	# Segunda seed
	spawn_controller.respawn_with_new_seed(99999)
	await get_tree().create_timer(0.5).timeout
	var second_info = spawn_controller.spawn_info.duplicate(true)
	
	# Verifica se são diferentes
	var different = false
	if first_info.size() == second_info.size():
		for i in range(first_info.size()):
			if first_info[i].seed != second_info[i].seed:
				different = true
				break
	else:
		different = true
	
	if different:
		print("SUCESSO: Seeds diferentes geraram resultados diferentes!")
		print("   Seed 1: 11111 (", first_info.size(), " criaturas)")
		print("   Seed 2: 99999 (", second_info.size(), " criaturas)")
	else:
		print("FALHA: Seeds diferentes geraram mesmos resultados!")

func _test_shiny_rate() -> void:
	print("Testando taxa de aparição de criaturas shiny...")
	print("Gerando 100 criaturas para análise estatística...")
	
	var total_creatures = 0
	var shiny_count = 0
	var iterations = 10
	
	for i in range(iterations):
		spawn_controller.respawn_with_new_seed()
		await get_tree().create_timer(0.3).timeout
		
		for info in spawn_controller.spawn_info:
			total_creatures += 1
			if info.is_shiny:
				shiny_count += 1
	
	var shiny_rate = (float(shiny_count) / float(total_creatures)) * 100.0
	var expected_rate = (1.0 / 4096.0) * 100.0
	
	print("Análise completa:")
	print("   Total de criaturas: ", total_creatures)
	print("   Criaturas shiny: ", shiny_count)
	print("   Taxa obtida: ", "%.4f" % shiny_rate, "%")
	print("   Taxa esperada: ", "%.4f" % expected_rate, "% (1/4096)")
	print("   Diferença: ", "%.4f" % abs(shiny_rate - expected_rate), "%")
	
	if shiny_count > 0:
		print("Pelo menos um shiny encontrado!")

func _input(event: InputEvent) -> void:
	# Teclas de atalho para testes
	if event.is_action_pressed("ui_text_backspace"):  # Backspace
		print("\nRespawn com nova seed...")
		spawn_controller.respawn_with_new_seed()
	
	if event.is_action_pressed("ui_text_delete"):  # Delete
		print("\nRespawn com mesma seed...")
		spawn_controller.respawn_same_seed()
	
	if event.is_action_pressed("ui_page_up"):  # Page Up
		print("\nImprimindo informações de spawn...")
		spawn_controller.print_spawn_info()
