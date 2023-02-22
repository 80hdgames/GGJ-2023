extends Node3D

const SPEED = 50

@export var rotate_vector: Vector3 = Vector3(0.0, 1.0, 0.0)

func _physics_process(delta):
	rotation_degrees += rotate_vector * delta * SPEED
