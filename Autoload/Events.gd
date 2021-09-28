extends Node

## Signal emitted when the player place the entity on the map
## passing the entity and its position
signal entity_placed(entity, position_cellv)

## Signal emitted when the player remove the entity from the map
## passing the entity and its position
signal entity_removed(entity, position_cellv)
