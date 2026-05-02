extends CharacterBody3D

## Player com sistema de animações
## Suporta: Idle, Walk, Run, Jump

# Constantes de movimento
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Estados de animação
enum AnimState {
	IDLE,
	WALKING,
	JUMPING,
	FALLING
}

# Referências
@onready var anim_player: AnimationPlayer = $gobot/AnimationPlayer
@onready var model: Node3D = $gobot

# Estado atual
var current_anim_state: AnimState = AnimState.IDLE
var is_jumping: bool = false

func _ready() -> void:
	# Verifica se AnimationPlayer existe
	if not anim_player:
		push_warning("AnimationPlayer não encontrado no Player!")

func _physics_process(delta: float) -> void:
	# Aplica gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		# Reseta flag de pulo quando toca o chão
		if is_jumping:
			is_jumping = false

	# Input de pulo
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_jumping = true

	# Input de movimento
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# Atualiza animações
	_update_animation_state(direction)
	
	move_and_slide()

## Atualiza o estado de animação baseado no movimento
func _update_animation_state(direction: Vector3) -> void:
	if not anim_player:
		return
	
	var new_state: AnimState
	
	# Determina novo estado
	if is_jumping or not is_on_floor():
		if velocity.y > 0:
			new_state = AnimState.JUMPING
		else:
			new_state = AnimState.FALLING
	elif direction.length() > 0.1:
		new_state = AnimState.WALKING
	else:
		new_state = AnimState.IDLE
	
	# Só muda animação se o estado mudou
	if new_state != current_anim_state:
		current_anim_state = new_state
		_play_animation_for_state(current_anim_state)

## Toca a animação apropriada para o estado
func _play_animation_for_state(state: AnimState) -> void:
	if not anim_player:
		return
	
	match state:
		AnimState.IDLE:
			_play_animation_safe("Idle")
		
		AnimState.WALKING:
			_play_animation_safe("Walk")
		
		AnimState.JUMPING:
			_play_animation_safe("Jump")
		
		AnimState.FALLING:
			# Usa animação de Jump também para queda, ou cria uma específica
			_play_animation_safe("Jump")

## Toca animação verificando se existe
func _play_animation_safe(anim_name: String) -> void:
	if not anim_player:
		return
	
	# Tenta várias variações do nome
	var variations = [anim_name, anim_name.to_lower(), anim_name.to_upper()]
	
	for variation in variations:
		if anim_player.has_animation(variation):
			# Só toca se não estiver já tocando
			if anim_player.current_animation != variation:
				anim_player.play(variation)
			return
	
	# Se não encontrou, avisa
	push_warning("Animação não encontrada: " + anim_name)

## Debug: Imprime animações disponíveis
func print_available_animations() -> void:
	if not anim_player:
		return
	
	print("\n=== ANIMAÇÕES DISPONÍVEIS NO PLAYER ===")
	var animation_list = anim_player.get_animation_list()
	for anim_name in animation_list:
		print("  - ", anim_name)
	print("Total: ", animation_list.size(), " animações")
