@tool
extends Node3D

enum FEATURE_SET {
	CITY,
	PARK,
	ROAD,
}

const ROAD_RADIUS = 2
const FEATURE_SET_COLORS = [
	Color.SLATE_GRAY,
	Color.SEA_GREEN,
	Color.DIM_GRAY,
]

@export_range(0.0, 10.0, 1.0, "suffix:m", "prefer_slider") var tile_size := 2.0:
	set(value):
		tile_size = value
		scale = Vector3(value, value, value)

@export_subgroup("Generation", "gen_")
@export_range(0, 100, 1, "suffix:%", "prefer_slider") var gen_road_placement := 50:
	set(value):
		gen_road_placement = value
		regenerate = true
@export_range(0, 4, 1, "suffix:Tiles") var gen_padding := 2:
	set(value):
		gen_padding = value
		regenerate = true
@export_range(16, 64, 1, "suffix:Tiles", "prefer_slider", "or_greater") var gen_width := 16:
	set(value):
		gen_width = value
		regenerate = true
@export_range(16, 64, 1, "suffix:Tiles", "prefer_slider", "or_greater") var gen_height := 24:
	set(value):
		gen_height = value
		regenerate = true
@export var randomize_room := false:
	set(value):
		if value:
			gen_road_placement = random.randi_range(0, 100)
			gen_padding = random.randi_range(2, 4)
			gen_width = random.randi_range(16, 64)
			gen_height = random.randi_range(16, 64)
			regenerate = true
		randomize_room = false

var random = RandomNumberGenerator.new()
var regenerate = true
var tiles: Array[FEATURE_SET]

@onready var tile_mesh: MultiMeshInstance3D = $Mesh

func _ready() -> void:
	var batch = MultiMesh.new()
	batch.transform_format = MultiMesh.TRANSFORM_3D
	batch.use_colors = true
	
	var mesh = PlaneMesh.new()
	mesh.material = load("res://materials/debug/mapgen.tres")
	batch.mesh = mesh
	tile_mesh.multimesh = batch

func _process(_dt) -> void:
	if regenerate:
		regenerate = false
		
		# Generate tile types
		tiles = _generate_tiles()
		
		# Generate tile mesh
		var batch = tile_mesh.multimesh
		batch.instance_count = gen_width * gen_height
		for z in range(0, gen_height):
			for x in range(0, gen_width):
				var i = z * gen_width + x
				var featureset = tiles.get(i)
				batch.set_instance_color(i, FEATURE_SET_COLORS[featureset])
				batch.set_instance_transform(i, Transform3D.IDENTITY.translated(Vector3(x, 0, z)))
		
		# City features
		
		# Park features

func _generate_tiles() -> Array[FEATURE_SET]:
	var arr: Array[FEATURE_SET] = []
	arr.resize(gen_width * gen_height)
	arr.fill(FEATURE_SET.CITY)
	
	# Place road
	var road_range = gen_height - 2 * (ROAD_RADIUS + gen_padding)
	var road = round((road_range * gen_road_placement / 100.0)) + ROAD_RADIUS + gen_padding
	for z in range(road - ROAD_RADIUS, road + ROAD_RADIUS):
		for x in range(0, gen_width):
			arr.set(z * gen_width + x, FEATURE_SET.ROAD)
	
	return arr
