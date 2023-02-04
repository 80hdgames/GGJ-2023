extends Node3D

@export var rotateVector :Vector3 = Vector3(0.0, 1.0, 0.0)
const SPEED = 50

func _physics_process(delta):
	rotation_degrees += rotateVector * delta * SPEED
