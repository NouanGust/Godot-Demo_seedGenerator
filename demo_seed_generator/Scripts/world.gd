extends Node3D

@export var spawn_zones: Array[Area3D]

func _ready() -> void:
	for zone in spawn_zones:
		print("Zona registrada: ", zone.name)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
