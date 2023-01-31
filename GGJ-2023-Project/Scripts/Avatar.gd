class_name Avatar extends Node3D

@onready var animPlayer :AnimationPlayer = $AnimationPlayer


func play(animName :String):
	animPlayer.play(animName, 0.3)
