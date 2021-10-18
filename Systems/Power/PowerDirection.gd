extends Node2D

# Arrows from the sprite sheet in a dictionary keyed with a descriptions of which way 
# the arrow faces.

const REGIONS := {
	"UpLeft": Rect2(899, 134, 31, 17),
	"DownRight": Rect2(950, 179, 31, 17),
	"UpRight": Rect2(950, 134, 31, 17),
	"DownLeft": Rect2(988, 179, 31, 17)
}

## A se of flags based on our `Types.Direction` enum. Allows you to choose the output
## direction(s) for the entity.

export (Types.Direction, FlAGS) var output_directions: int = 15 setget _set_output_directions

## References to the scene's four sprite nodes.
onready var west := $W
onready var north := $N
onready var east := $E
onready var south := $S

## Compares the output directions to the `Types.Direction` enum and assigns the correct
## arrow texture to it.
func set_indicators() -> void:
	# If LEFT's bits are in `output_directions`
	if output_directions & Types.Direction.LEFT != 0:
		# ...set the west arrow to point out
		west.region_rect = REGIONS.UpLeft
	else:
		# ...otherwise, set it to point in by using the bottom right arrow graphic
		west.region_rect = REGIONS.DownRight

	# Repeat for all four arrows individually
	if output_directions & Types.Direction.RIGHT != 0:
		east.region_rect = REGIONS.DownRight
	else:
		east.region_rect = REGIONS.UpLeft
	
	if output_directions & Types.Direction.UP != 0:
		north.region_rect = REGIONS.UpRight
	else:
		north.region_rect = REGIONS.DownLeft

	if output_directions & Types.Direction.DOWN != 0:
		south.region_rect = REGIONS.DownLeft
	else:
		south.region_rect = REGIONS.UpRight


## The setter for the blueprint's direction value.
func _set_output_directions(value: int) -> void:
	output_directions = value

	# Wait until the blueprint has appeared in the scene tree at least once.
	# We must do this as setters get called _before_ the node is in the scenetree, 
	# meaning the sprites are not yet in their onready variables.
	if not is_inside_tree():
		yield(self, "ready")

	# Set the sprite graphics according to the direction value.
	set_indicators()

