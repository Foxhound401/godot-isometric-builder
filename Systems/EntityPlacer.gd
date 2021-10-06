extends TileMap

## Distance from the player when the mouse stops being able to interact.
const MAXIMUM_WORK_DISTANCE := 275.0

const POSITION_OFFSET := Vector2(0, 0)
# const POSITION_OFFSET := Vector2(0, 25)
const DECONSTRUCT_TIME := 0.3

var _current_deconstruct_location := Vector2.ZERO


var _blueprint: BlueprintEntity

var _tracker: EntityTracker

var _ground: TileMap

var _player: KinematicBody2D

onready var Library := {
	"StirlingEngine": preload("res://Entities/Blueprints/StirlingEngineBlueprint.tscn").instance(),
}

onready var _deconstruct_timer := $Timer

func _process(_delta: float) -> void:
	var has_placeable_blueprint: bool = _blueprint and _blueprint.placeable

	if has_placeable_blueprint:
		_move_blueprint_in_world(world_to_map(get_global_mouse_position()))

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

	if event is InputEventMouseMotion:
		_abort_deconstruct()

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

	elif event.is_action_pressed("right_click") and not has_placeable_blueprint:
		if cell_is_occupied and is_close_to_player:
			_deconstruct(global_mouse_position, cellv)

	elif event is InputEventMouseMotion:
		if cellv != _current_deconstruct_location:
			_abort_deconstruct()

func _move_blueprint_in_world(cellv: Vector2) -> void:
	## check this because it has the POSITION_OFFSET
	_blueprint.global_position = map_to_world(cellv) + POSITION_OFFSET

	var is_close_to_player := (
		get_global_mouse_position().distance_to(_player.global_position) < MAXIMUM_WORK_DISTANCE
	)

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

func _deconstruct(event_position: Vector2, cellv: Vector2) -> void:
	_deconstruct_timer.connect("timeout", self, "_finish_deconstruct", [cellv], CONNECT_ONESHOT)
	_deconstruct_timer.start(DECONSTRUCT_TIME)
	_current_deconstruct_location = cellv

func _finish_deconstruct(cellv: Vector2) -> void:
	var entity := _tracker.get_entity_at(cellv)
	_tracker.remove_entity(cellv)

func _abort_deconstruct() -> void:
	print(_deconstruct_timer)
	if _deconstruct_timer.is_connected("timeout", self, "_finish_deconstruct"):
		_deconstruct_timer.disconnect("timeout", self, "_finish_deconstruct")
	_deconstruct_timer.stop()
