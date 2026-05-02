extends Node3D
class_name ShinyEffects

## Sistema de efeitos visuais para criaturas Shiny
## Adiciona partículas, brilho e animações especiais

# Referências
var particle_system: GPUParticles3D
var light: OmniLight3D
var animation_timer: float = 0.0

# Configurações
@export var particle_color: Color = Color(1.0, 0.9, 0.0, 1.0)
@export var light_color: Color = Color(1.0, 0.9, 0.0)
@export var light_energy: float = 0.5
@export var pulse_speed: float = 2.0

func _ready() -> void:
	_create_particle_system()
	_create_light()

func _process(delta: float) -> void:
	_update_pulse_effect(delta)

## Cria sistema de partículas
func _create_particle_system() -> void:
	particle_system = GPUParticles3D.new()
	add_child(particle_system)
	
	# Configurações básicas
	particle_system.emitting = true
	particle_system.amount = 20
	particle_system.lifetime = 2.0
	particle_system.explosiveness = 0.0
	particle_system.randomness = 0.5
	particle_system.visibility_aabb = AABB(Vector3(-2, -2, -2), Vector3(4, 4, 4))
	
	# Material de partícula
	var material = ParticleProcessMaterial.new()
	
	# Emissão
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 0.5
	
	# Direção e velocidade
	material.direction = Vector3(0, 1, 0)
	material.spread = 45.0
	material.initial_velocity_min = 0.5
	material.initial_velocity_max = 1.0
	
	# Gravidade
	material.gravity = Vector3(0, 0.5, 0)
	
	# Escala
	material.scale_min = 0.05
	material.scale_max = 0.15
	
	# Cor
	material.color = particle_color
	
	# Fade
	var gradient = Gradient.new()
	gradient.set_color(0, particle_color)
	gradient.set_color(1, Color(particle_color.r, particle_color.g, particle_color.b, 0.0))
	
	var gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = gradient
	material.color_ramp = gradient_texture
	
	particle_system.process_material = material
	
	# Mesh de partícula (pequena esfera)
	var mesh = SphereMesh.new()
	mesh.radial_segments = 8
	mesh.rings = 4
	mesh.radius = 0.05
	mesh.height = 0.1
	particle_system.draw_pass_1 = mesh

## Cria luz pulsante
func _create_light() -> void:
	light = OmniLight3D.new()
	add_child(light)
	
	light.light_color = light_color
	light.light_energy = light_energy
	light.omni_range = 2.0
	light.omni_attenuation = 2.0
	light.shadow_enabled = false  # Performance

## Atualiza efeito de pulsação
func _update_pulse_effect(delta: float) -> void:
	if not light:
		return
	
	animation_timer += delta * pulse_speed
	
	# Oscila entre 50% e 100% da energia
	var pulse = 0.5 + (sin(animation_timer) * 0.5 + 0.5) * 0.5
	light.light_energy = light_energy * pulse

## Define cor dos efeitos
func set_effect_color(color: Color) -> void:
	particle_color = color
	light_color = color
	
	if particle_system and particle_system.process_material:
		var material = particle_system.process_material as ParticleProcessMaterial
		if material:
			material.color = color
	
	if light:
		light.light_color = color

## Liga/desliga efeitos
func set_effects_enabled(enabled: bool) -> void:
	if particle_system:
		particle_system.emitting = enabled
	
	if light:
		light.visible = enabled

## Cria efeito de spawn especial
func play_spawn_effect() -> void:
	if not particle_system:
		return
	
	# Burst de partículas no spawn
	particle_system.amount = 50
	particle_system.explosiveness = 1.0
	
	# Volta ao normal após 1 segundo
	await get_tree().create_timer(1.0).timeout
	
	if particle_system:
		particle_system.amount = 20
		particle_system.explosiveness = 0.0

## Factory: Cria efeitos para abelha shiny
static func create_for_abelha_shiny(parent: Node3D) -> ShinyEffects:
	var effects = ShinyEffects.new()
	effects.particle_color = Color(1.0, 0.84, 0.0, 0.8)  # Dourado
	effects.light_color = Color(1.0, 0.9, 0.0)
	effects.light_energy = 0.6
	effects.pulse_speed = 2.5
	parent.add_child(effects)
	effects.position = Vector3(0, 0.5, 0)  # Acima da criatura
	return effects

## Factory: Cria efeitos para besouro shiny
static func create_for_besouro_shiny(parent: Node3D) -> ShinyEffects:
	var effects = ShinyEffects.new()
	effects.particle_color = Color(0.4, 0.2, 1.0, 0.8)  # Roxo-azul
	effects.light_color = Color(0.5, 0.3, 1.0)
	effects.light_energy = 0.7
	effects.pulse_speed = 3.0
	parent.add_child(effects)
	effects.position = Vector3(0, 0.4, 0)  # Acima da criatura
	return effects

## Factory: Cria efeitos genéricos
static func create_generic_shiny(parent: Node3D, color: Color) -> ShinyEffects:
	var effects = ShinyEffects.new()
	effects.particle_color = color
	effects.light_color = color
	effects.light_energy = 0.5
	effects.pulse_speed = 2.0
	parent.add_child(effects)
	effects.position = Vector3(0, 0.5, 0)
	return effects
