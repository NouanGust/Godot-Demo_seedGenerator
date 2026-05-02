extends Node3D

@export var bicho_list:Array[PackedScene]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for bicho in bicho_list:
		bicho.instantiate()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
