class_name Aftermath extends Node

@onready var cam = $Camera3D

func begin():
	cam.current = true
