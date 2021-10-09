class_name Types
extends Reference

## We store constatns for possible directions: up, down, left, right.
## We'll use bitwise operator to combine them, allowing us to map directions
## to different wire sprites.

## For example, if we combine RIGHT and DOWN below, we will get the number '3'.
## We write thsese numbers in base 10. If you prefer, you can write them in binary using the
## prefix 0b. For example, 0b001 is the number '1' in binary, and ob1000 is the number '8'.

enum Direction {RIGHT = 1, DOWN = 2, LEFT = 4, UP = 8}

## This is dictionary maps our 'Direction' values to 'Vector2' cordinates, to loop over neighbors of
## a given cell.

const NEIGHBORS := {
	Direction.RIGHT: Vector2.RIGHT,
	Direction.DOWN: Vector2.DOWN,
	Direction.LEFT: Vector2.LEFT,
	Direction.UP: Vector2.UP
}

# Group name constants. Storing them as constatnts help prevent typos.
const POWER_MOVERS := "power_movers"
const POWER_RECEIVERS := "power_receivers"
const POWER_SOURCES := "power_sources"
