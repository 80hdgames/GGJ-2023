extends Node

var players :int = 1
var playerInstances :Array = []
const MAX_PLAYERS :int = 8


func set_player_count(amount :int):
	players = clamp(amount, 1, MAX_PLAYERS)
#	print("Player count now %s" % players)
#	print_stack()


func register_player_instance(p):
	playerInstances.append(p)
