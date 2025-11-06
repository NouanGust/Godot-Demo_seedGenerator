extends Node3D

@export var creatures: Array[PackedScene]
@export var spwan_zones: Array[Area3D]
@export var max_creatures: int = 10

var spawned_creatures: Array[Node3D] = []

func _ready() -> void:
	spawn_creatures()

func spawn_creatures():
	for i in range(max_creatures):
		var zone = spwan_zones.pick_random()
		var creature_scene = creatures.pick_random()
		
		var creature_instance = creature_scene.instantiate()
		var spawn_position = get_random_position_in_zone(zone)
		creature_instance.global_transform.origin = spawn_position
		add_child(creature_instance)
		spawned_creatures.append(creature_instance)
		

func get_random_position_in_zone(zone: Area3D):
	var shape = zone.get_node("CollisionShape3D").shape
	if shape is BoxShape3D:
		var extents = shape.extents
		var random_offset = Vector3(randf_range(-extents.x, extents.x), randf_range(-extents.y, extents.y), randf_range(-extents.z, extents.z))
		return zone.global_transform.origin + random_offset
	else:
		push_warning("Forma de spawn não suportada para " + zone.name)
		return zone.global_transform.origin 
