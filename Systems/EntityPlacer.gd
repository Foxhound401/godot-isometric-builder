extends TileMap

## Distance from the player when the mouse stops being able to interact.
const MAXIMUM_WORK_DISTANCE := 275.0

# const POSITION_OFFSET := Vector2(0, 0)
const POSITION_OFFSET := Vector2(0, 25)
const DECONSTRUCT_TIME := 0.3

var _current_deconstruct_location := Vector2.ZERO


var _blueprint: BlueprintEntity

var _tracker: EntityTracker

var _ground: TileMap

var _player: KinematicBody2D

var _flat_entities: YSort

onready var Library := {
	"StirlingEngine": preload("res://Entities/Blueprints/StirlingEngineBlueprint.tscn").instance(),
	"Wire": preload("res://Entities/Blueprints/WireBlueprint.tscn").instance(),
}

onready var _deconstruct_timer := $Timer

func _process(_delta: float) -> void:
	var has_placeable_blueprint: bool = _blueprint and _blueprint.placeable

	if has_placeable_blueprint:
		_move_blueprint_in_world(world_to_map(get_global_mouse_position()))

func _ready() -> void:
	Library[Library.StirlingEngine] = preload("res://Entities/Entities/StirlingEngineEntity.tscn")
	Library[Library.Wire] = preload("res://Entities/Entities/WireEntity.tscn")

func _exit_tree() -> void:
	Library.StirlingEngine.queue_free()
	Library.Wire.queue_free()

## Setup
func setup(entities) -> void:
	_tracker = entities.tracker
	_ground = entities.ground
	_player = entities.player
	_flat_entities = entities.flat_entities

	for child in get_children():
		if child is Entity:
			var map_position := world_to_map(child.global_position)

			_tracker.place_entity(child, map_position)

## Unhandled Input
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
				_update_neighboring_flat_entities(cellv)

	elif event.is_action_pressed("right_click") and not has_placeable_blueprint:
		if cell_is_occupied and is_close_to_player:
			_deconstruct(global_mouse_position, cellv)

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

	# We duplicate the temporary hard-coded shortcut above.
	elif event.is_action_pressed("quickbar_2"):
		if _blueprint:
			remove_child(_blueprint)
		# This is the only difference: we assign the `WireBlueprint` to the `_blueprint` variable
		_blueprint = Library.Wire
		add_child(_blueprint)
		_move_blueprint_in_world(cellv)


	elif event is InputEventMouseMotion:
		if cellv != _current_deconstruct_location:
			_abort_deconstruct()

## Move Blueprint
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

	if _blueprint is WireBlueprint:
		WireBlueprint.set_sprite_for_direction(_blueprint.sprite, _get_powered_neighbors(cellv))

## Place Entity
func _place_entity(cellv: Vector2) -> void:
	var new_entity: Node2D = Library[_blueprint].instance()

	if _blueprint is WireBlueprint:
		var directions := _get_powered_neighbors(cellv)
		_flat_entities.add_child(new_entity)
		WireBlueprint.set_sprite_for_direction(new_entity.sprite, directions)
	else:
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

	_update_neighboring_flat_entities(cellv)

func _abort_deconstruct() -> void:
	if _deconstruct_timer.is_connected("timeout", self, "_finish_deconstruct"):
		_deconstruct_timer.disconnect("timeout", self, "_finish_deconstruct")
	_deconstruct_timer.stop()


## Returns a bit-wise integer based on whether the nearby objects can carry power.
func _get_powered_neighbors(cellv: Vector2) -> int:
	# Begin with a blank direction of 0
	var direction := 0

	# We loop oever each neighboring direction from our `Types.NEIGHBORS` dictionary.
	for neighbor in Types.NEIGHBORS.keys():
		# We calculate the neighbor cell's coordinates.
		var key: Vector2 = cellv + Types.NEIGHBORS[neighbor]

		# We get the netity in that cell if there is one.
		if _tracker.is_cell_occupied(key):
			var entity: Node = _tracker.get_entity_at(key)
			
			# If the entity is part of any of the power groups.
			if (
				entity.is_in_group(Types.POWER_MOVERS)
				or entity.is_in_group(Types.POWER_RECEIVERS)
				or entity.is_in_group(Types.POWER_SOURCES)
			):
				# We combine the number with the OR bitwise operator.
				# It's like using +=, but | prevents the same number from adding to itself.
				# Types.Direction.RIGHT (1) + Types.Direction.RIGHT (1) results in DOWN(2),
				# which is wrong.
				#
				# Types.Direction.RIGHT (1) | Types.Direction.RIGHT (1) still results in RIGHT (1).
				#
				# Since we are iterating over all four directions and will not repeat, you can use+,
				# but I use the | operator to be more explicit about comparing bitwise enum FLAGS.
				direction |= neighbor

	return direction

## Looks at each of the neighboring tiles and updates each of hem to use the 
## correct graphics based on their own neighbors.

func _update_neighboring_flat_entities(cellv: Vector2) -> void:
	# For each neighboring tile.
	for neighbor in Types.NEIGHBORS.keys():
		# We get the entity, if there is one

		# I have not understand the way the cheking work
		var key: Vector2 = cellv + Types.NEIGHBORS[neighbor]
		var object = _tracker.get_entity_at(key)

		# If it's a wire, we have that wire update its graphics to connect to the new entity.
		if object and object is WireEntity:
			var tile_directions := _get_powered_neighbors(key)
			print(tile_directions)
			WireBlueprint.set_sprite_for_direction(object.sprite, tile_directions)


