extends Node3D

const PLAYER_PREFAB = preload("res://Scenes/Prefabs/Piggy.tscn")
const PLAYER_POSITIONS = [
	Vector3.ZERO,
	Vector3.FORWARD,
	Vector3.BACK,
	Vector3.LEFT,
	Vector3.RIGHT,
	Vector3.FORWARD * 2,
	Vector3.BACK * 2,
	Vector3.LEFT * 2,
]

var playerInstances :Array = []


func _ready():
	# instance desired players
	for i in range(PlayerManager.players):
		var p = PLAYER_PREFAB.instantiate()
		add_child(p, true)
		playerInstances.append(p)
		p.global_transform.origin = PLAYER_POSITIONS[i]
