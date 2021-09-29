extends TileMap

## Distance from the player when the mouse stops being able to interact.
const MAXIMUM_WORK_DISTANCE := 275.0

const POSITION_OFFSET := Vector2(0, 0)
# const POSITION_OFFSET := Vector2(0, 25)

var _blueprint: BlueprintEntity

var _tracker: EntityTracker

var _ground: TileMap

var _player: KinematicBody2D

onready var Library := {
	"StirlingEngine": preload("res://Entities/Blueprints/StirlingEngineBlueprint.tscn").instance(),
}

func _ready() -> void:
	print("BLUEPRINT")
	print(_blueprint)
	Library[Library.StirlingEngine] = preload("res://Entities/Entities/StirlingEngineEntity.tscn")

func _exit_tree() -> void:
	Library.StirlingEngine.queue_free()

func setup(tracker: EntityTracker, ground: TileMap, player: KinematicBody2D) -> void:
	_tracker = tracker
	_ground = ground
	_player = player

	for child in get_children():
		if child is Entity:
			var map_position := world_to_map(child.global_position)

			_tracker.place_entity(child, map_position)


func _unhandled_input(event: InputEvent) -> void:
	var global_mouse_position := get_global_mouse_position()

	var has_placeable_blueprint: bool = _blueprint and _blueprint.placeable

	var is_close_to_player := (
		global_mouse_position.distance_to(_player.global_position) < MAXIMUM_WORK_DISTANCE
	)
	
	var cellv := world_to_map(global_mouse_position)

	var cell_is_occupied := _tracker.is_cell_occupied(cellv)

	var is_on_ground := _ground.get_cellv(cellv) == 0

	if event.is_action_pressed("left_click"):
		if has_placeable_blueprint:
			if not cell_is_occupied and is_close_to_player and is_on_ground:
				_place_entity(cellv)

	elif event is InputEventMouseMotion:
		if has_placeable_blueprint:
			_move_blueprint_in_world(cellv)

	elif event.is_action_pressed("drop") and _blueprint:
		remove_child(_blueprint)
		_blueprint = null

	elif event.is_action_pressed("quickbar_1"):
		if _blueprint:
			remove_child(_blueprint)
		_blueprint = Library.StirlingEngine
		add_child(_blueprint)
		_move_blueprint_in_world(cellv)


func _move_blueprint_in_world(cellv: Vector2) -> void:
	## check this because it has the POSITION_OFFSET
	_blueprint.global_position = map_to_world(cellv) + POSITION_OFFSET

	var is_close_to_player := (
		get_global_mouse_position().distance_to(_player.global_position) < MAXIMUM_WORK_DISTANCE
	)

	print("GROUND CELL")
	print(_ground.get_cellv(cellv))
	var is_on_ground: bool = _ground.get_cellv(cellv) == 0
	var cell_is_occupied := _tracker.is_cell_occupied(cellv)

	if not cell_is_occupied and is_close_to_player and is_on_ground:
		_blueprint.modulate = Color.white
	else:
		_blueprint.modulate = Color.red

func _place_entity(cellv: Vector2) -> void:
	var new_entity: Node2D = Library[_blueprint].instance()

	add_child(new_entity)

	new_entity.global_position = map_to_world(cellv) + POSITION_OFFSET

	new_entity._setup(_blueprint)

	_tracker.place_entity(new_entity, cellv)
