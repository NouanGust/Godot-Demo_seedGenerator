extends CharacterBody3D
class_name Creature

@export var move_radius: float = 5.0
@export var move_speed: float = 2.0
@export var idle_time: float = 2.0
@export var gravity: float = 9.8  

var start_position: Vector3
var target_position: Vector3
var is_moving: bool = false
var idle_timer: float = 0.0
var vertical_velocity: float = 0.0 

@onready var animation_player: AnimationPlayer = get_node(str(get_tree()) + "AnimationPlayer")

func _ready():
	start_position = global_position
	print(get_node(str(get_tree()) + "AnimationPlayer"))
	_pick_new_target()

func _physics_process(delta):
	_apply_gravity(delta)

	if is_moving:
		_move_towards_target(delta)
	else:
		idle_timer -= delta
		if idle_timer <= 0:
			_pick_new_target()

	move_and_slide()

func _apply_gravity(delta):
	if not is_on_floor():
		vertical_velocity -= gravity * delta
	else:
		vertical_velocity = 0.0

	velocity.y = vertical_velocity

func _move_towards_target(delta):
	var direction = target_position - global_position
	direction.y = 0 

	if direction.length() < 0.2:
		_stop_moving()
		return

	direction = direction.normalized()
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed
	
	look_at(global_position - direction, Vector3.UP)
	animation_player.play("walk")

func _stop_moving():
	is_moving = false
	velocity.x = 0
	velocity.z = 0
	animation_player.play("idle")
	idle_timer = randf_range(idle_time * 0.5, idle_time * 1.5)

func _pick_new_target():
	var random_offset = Vector3(
		randf_range(-move_radius, move_radius),
		0,
		randf_range(-move_radius, move_radius)
	)
	target_position = start_position + random_offset
	is_moving = true
