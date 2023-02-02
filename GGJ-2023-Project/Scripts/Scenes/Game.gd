extends Node3D

const MusicType = MusicManager.MusicType

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
	# make a node to store all players in
	var playersNode :Node = Node.new()
	playersNode.name = "Players"
	add_child(playersNode)
	move_child(playersNode, 0) # move to top
	# instance desired players
	for i in range(PlayerManager.players):
		var p = PLAYER_PREFAB.instantiate()
		p.name += str(i) # append index on end of name
		playersNode.add_child(p, true)
		playerInstances.append(p)
		p.global_transform.origin = PLAYER_POSITIONS[i]
		playersNode.move_child(p, 0) # reverse order of players so player 1 grabs first input
		p.set_player_id(i) # tint the scarf
