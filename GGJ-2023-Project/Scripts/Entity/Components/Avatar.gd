class_name Avatar extends Node3D

@onready var animPlayer :AnimationPlayer = $AnimationPlayer

const ONE_SHOT_ANIMATIONS :Array[String] = [
	"Land",
	"Jump",
	"Dig"
]


func play(animName :String, blend :float = 0.3):
	if _is_playing_one_shot_anim():
		return
	animPlayer.play(animName, blend)


func play_one_shot(animName :String, blend :float = 0.3):
	animPlayer.stop(true)
	play(animName, blend)


func _is_playing_one_shot_anim():
	return ONE_SHOT_ANIMATIONS.has(animPlayer.current_animation)
