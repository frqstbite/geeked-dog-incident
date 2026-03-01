extends Node3D

const MAX_HUMAN_COUNT = 10

@export var human_scene : PackedScene

var human_count = 0
var human_spawn_delay : float = 1.0

var human_list : Array[CharacterBody3D] = []
var spawn_list : Array[Vector3] = []
var children_list : Array[Node] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	children_list = get_children()
	for child in children_list:
		if child is Node3D:
			spawn_list.append(child.position)
			child.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if human_spawn_delay <= 0:
		spawn_human()
		human_spawn_delay = randf_range(3, 10)
	
	human_spawn_delay -= delta

func spawn_human() -> CharacterBody3D:
	var h : CharacterBody3D = human_scene.instantiate()
	h.position = spawn_list[randi_range(0, spawn_list.size() - 1)]
	human_list.append(h)
	add_sibling(h)
	return h
	
