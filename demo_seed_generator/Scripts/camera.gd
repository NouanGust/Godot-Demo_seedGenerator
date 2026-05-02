extends Camera3D

var sense: float = 0.005

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		get_parent().rotate_y(-event.relative.x * sense)
		rotate_x(-event.relative.y * sense)
		rotation.x = clamp(rotation.x, deg_to_rad(-90), deg_to_rad(90))
	if event.is_action_pressed("quit"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _process(delta: float) -> void:
	pass
