extends Node


signal player_count_changed

var players :int = 1
var playerInstances :Array = []
const MAX_PLAYERS :int = 8


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS


func set_player_count(amount :int):
	players = clamp(amount, 1, MAX_PLAYERS)
#	print("Player count now %s" % players)
#	print_stack()
	emit_signal("player_count_changed")


func register_player_instance(p :Node3D):
	if not playerInstances.has(p):
		playerInstances.append(p)
		p.tree_exiting.connect(_cleanup.bind(p))


func _cleanup(p):
	playerInstances.erase(p)
