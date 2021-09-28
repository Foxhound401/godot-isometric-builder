extends KinematicBody2D

## Movement speed in pixels per second
export var movement_speed := 500.0

func _physics_process(_delta: float) -> void:
	# move the player at constant speed based on the input direction.
	var direction :=_get_direction()
	move_and_slide(direction * movement_speed)


func _get_direction() -> Vector2:
	# reason for * 2.0 is the isometric tile, 2:1 ratio speed up the horizontal movement to feel consistent.
	return Vector2(Input.get_action_strength("right") - Input.get_action_strength("left") * 2.0, Input.get_action_strength("down") - Input.get_action_strength("up")).normalized()
