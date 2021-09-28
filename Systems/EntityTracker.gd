extends Reference
class_name EntityTracker

## A Dictionary of entities, keyed using 'Vector2' tilemap coordinates.
var entities := {}

func place_entity(entity, cellv: Vector2) -> void:
	## Check if the cellv already exist in this position
	## in the map, do nothing if true
	if entities.has(cellv):
		return

	entities[cellv] = entity

	Events.emit_signal("entity_placed", entity, cellv)


func remove_entity(cellv: Vector2) -> void:
	## check if there are entity at that localtion
	if not entities.has(cellv):
		return

	## Get the entity, remove it out of the entities dictionary
	## emit signal of its removal and queue it up for removal
	var entity = entities[cellv]
	var _result := entities.erase(cellv)
	Events.emit_signal("entity_removed", entity, cellv)

	entity.queue_free()


## return true if there is an enity at the given location
func is_cell_occupied(cellv: Vector2) -> bool:
	return entities.has(cellv)

## Returns the entity at the given location, if it exists, or null otherwise
func get_entity_at(cellv: Vector2) -> Node2D:
	if entities.has(cellv):
		return entities[cellv]
	else:
		return null
