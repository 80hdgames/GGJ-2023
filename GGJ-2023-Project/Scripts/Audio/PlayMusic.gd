extends Node

const MusicType = MusicManager.MusicType

@export var type :MusicType


func _ready():
	call_deferred("_deferred_play")


func _deferred_play():
	MusicManager.enqueue(type)
	
