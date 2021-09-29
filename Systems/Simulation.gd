extends Node2D

const BARRIER_ID := 1
const INVISIBLE_BARRIER_ID := 2

## new is for the class,
var _tracker := EntityTracker.new()

onready var _ground := $GameWorld/GroundTiles
onready var _entity_placer := $GameWorld/YSort/EntityPlacer
onready var _player := $GameWorld/YSort/Player

func _ready() -> void:
	_entity_placer.setup(_tracker, _ground, _player)
	var barriers: Array = _ground.get_used_cells_by_id(BARRIER_ID)

	for barrier in barriers:
		_ground.set_cellv(barrier, INVISIBLE_BARRIER_ID)
