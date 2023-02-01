class_name Avatar extends Node3D

@onready var animPlayer :AnimationPlayer = $AnimationPlayer


func play(animName :String, blend :float = 0.3):
	animPlayer.play(animName, blend)

func play_one_shot(animName :String):
	play("Idle", 0.0) # HACK: playing another animation in between forces the desired animation to restart
	play(animName)
