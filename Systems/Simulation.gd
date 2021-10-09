extends Node2D

const BARRIER_ID := 1
const INVISIBLE_BARRIER_ID := 2

## new is for the class,
var _tracker := EntityTracker.new()

onready var _ground := $GameWorld/GroundTiles
onready var _entity_placer := $GameWorld/YSort/EntityPlacer
onready var _player := $GameWorld/YSort/Player
onready var _flat_entities := $GameWorld/FlatEntities

func _ready() -> void:
	var entities = {
		"tracker": _tracker,
		"ground": _ground,
		"player": _player,
		"flat_entities": _flat_entities
	}

	_entity_placer.setup(entities)
	var barriers: Array = _ground.get_used_cells_by_id(BARRIER_ID)

	for barrier in barriers:
		_ground.set_cellv(barrier, INVISIBLE_BARRIER_ID)
