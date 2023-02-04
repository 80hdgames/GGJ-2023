class_name Aftermath extends Node

@onready var cam = $Camera3D

@onready var PLACES = [
	$First.global_position,
	$Second.global_position,
	$Third.global_position
]

func begin():
	cam.current = true
	
	# TODO: figure out raankings in here...
	var i: int = 0
	for p in PlayerManager.playerInstances:
		move_to_place(p, i)
		i += 1


func move_to_place(p :Node3D, i :int):
	if i < PLACES.size():
		p.global_position = PLACES[i]
