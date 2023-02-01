extends Node3D

const PLAYER_PREFAB = preload("res://Scenes/Prefabs/Piggy.tscn")
const PLAYER_POSITIONS = [
	Vector3.ZERO,
	Vector3.FORWARD * 2,
	Vector3.BACK * 2,
	Vector3.LEFT * 2,
	Vector3.RIGHT * 2,
	Vector3.FORWARD * 4,
	Vector3.BACK * 4,
	Vector3.LEFT * 4,
]

var playerInstances :Array = []


func _ready():
	# instance desired players
	for i in range(PlayerManager.players):
		var p = PLAYER_PREFAB.instantiate()
		add_child(p, true)
		playerInstances.append(p)
		p.global_transform.origin = PLAYER_POSITIONS[i]
