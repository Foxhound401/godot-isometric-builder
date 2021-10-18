## Component that can provide connected machines with electricity.
## Add it as a child node of to machines that produce energy.

class_name PowerSource
extends Node

## Signal for the power system to notify the component that it took
## a certain amount of power from the power source. Allows entities to react accordingly.
## For example, a battery can lower its stored amount or a generator can burn a tick of fuel.

signal power_updated(power_draw, delta)

## The maximum amount of power the machine can provide in units per tick.
export var power_amount := 10.0

## The possible directions for power to come `out` of the machine.
## The default value, 15, makes it omnidirectional.
## The FLAGS export hint below turns the value display in the Inspector into a checkbox list.

export (Types.Direction, FLAGS) var output_direction := 15

## How efficient the machine currently is. For instance, a machine that has no work
## to do has an efficienty of `0` where one that has a job has an efficiency of `1`.
var efficiency := 0.0

## Returns a float indicating the possible power multiplied by the current efficiency.
func get_effective_power() -> float:
	return power_amount * efficiency

## Replace all paths with new ones based on the components' current state.
func _retrace_paths() -> void:
	# Clear old paths.
	paths.clear()

	# For each power source...
	for source in power_sources.keys():
		# ... start a brand new path trace so all cells are possible contenders.
		cells_travelled.clear()

		# trace the path the current cell location, with an array with the source's 
		# cell as index 0.
		var path := _trace_path_from(source, [source])

		# And we add the result to the `paths` array.
		paths.push_back(path)

## Recursively trace a path from the source cell outwards, skipping already
## visited cells, going through cells recognized by the power system.
func _trace_path_from(cellv: Vector2, path: Array) -> Array:
	# As soon as we reach any given cell, we keep track that we've already visited it. 
	# Recursive function sare sensitive to overflowing, so this ensures we won't
	# travel back and forth between two cells forever until the game crashes.
	cells_travelled.push_back(cellv)

	# The default direction for most components, like the generator, is omni-directional,
	# that's UP + LEFT + RIGHT + DOWN in our Types.
	var direction := 15
	# If the current cell is a power source component, use _its_ direction instead.
	if power_sources.has(cellv):
		direction = power_sources[cellv].output_direction

	# get the power receivers that are neighbors to this cell, if there are any,
	# based on the direction.
	var receivers := _find_neighbors_in(cellv, power_receivers, direction)

	for receiver in receivers:
		if not receiver in cells_travelled and not receiver in path:
			# Create an integer that indicates the direction power is
			# traveling in to compare it to the receiver's direction.
			# For example, if the powr is traveling from left to right but the receiver
			# does not accept power coming from _its_ left, it should not be in the list.
			var combined_direction := _combine_directions(receiver, cellv)

## Compare a source to a target map position and return a direction integer
## that indicates the direction power is traveling in.
func _combine_directions(reciver: Vector2, cellv: Vector2) -> int:
	if receiver.x < cellv.x:
		return Types.Direction.LEFT
	elif receiver.x > cellv.x:
		return Types.Direction.RIGHT
	elif receiver.y < cellv.y:
		return Types.Direction.UP
	elif receiver.y > cellv.y:
		return Types.Direction.DOWN

	return 0

## For each neighbor in the given direction, check if it exists in the collection we specify
## and return an array of map positions with those that do.
func _find_neighbors_in(cellv: Vector2, collection: Dictionary, output_directions: int = 15) -> Array:
	var neighbors := []
	# For each of UP, DOWN, LEFT and RIGHT
	for neighbor in Types.NEIGHBORS.keys():
		# With binary numbers, comparing two values with the "&" operator compares binary bit 
		# of the two numbers.
		# resulting in a number whose bits that match are 1 and those that don't are 0.
		# For example, in binary, 1 is 0001, 2 is 0010, 3 is 0011, and 4 is 0100.
		# We can say that 3 contains 1 and 2 because 3 has both rightmost bits set to `1`, 
		# but `4 & 3` results in 0 because none of their bits match.
		# We can leverage these properties when working with flags to compare them. This is 
		# a common pattern, and we'll use it for our direction values.
		
		# This is condition means "if the current neighbor flag has bits that match the specified 
		# direction":
		if neighbor & output_directions != 0:
			# Cal culate its map coordinate
			var key: Vector2 = cellv + Types.NEIGHBORS[neighbor]

			# If it's in the spcified collection, add it to the neighbors array
			if collection.has(key):
				neighbors.push_back(key)

	# Return the array of neighbors that match the collection
	return neighbors


