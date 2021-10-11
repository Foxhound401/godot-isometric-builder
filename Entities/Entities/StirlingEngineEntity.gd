extends Entity

## use Tween animation to slowly increate the speed
## and shutdown

const BOOTUP_TIME := 6.0
const SHUTDOWN_TIME := 3.0

onready var animation_player := $AnimationPlayer
onready var tween := $Tween
onready var shaft := $PistonShaft
onready var power := $PowerSource

func _ready() -> void:
	## play the animation, which loops
	animation_player.play("Work")
	## Tween to control player's 'playback_speed'
	## making the engine feel like it sloly starting up unti it 
	## reaches the maximum speed.
	tween.interpolate_property(animation_player, "playback_speed", 0, 1, BOOTUP_TIME)
	tween.interpolate_property(power, "efficiency", 0, 1, BOOTUP_TIME)

	## read more about the interpolate, look like it take in the color and make it gradually 
	## change into that
	tween.interpolate_property(shaft, "modulate", Color.white, Color(0.5, 1, 0.5), BOOTUP_TIME)
	tween.start()

