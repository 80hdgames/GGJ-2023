extends Control

const PLAYER_NODE_GROUP = Constants.PLAYER_NODE_GROUP
const HUD_PLAYER = preload("res://Scenes/Prefabs/UI/HUDPlayer.tscn")

var playerHudLookup :Dictionary = {}
@onready var hudParent = $Margin/HBoxContainer


func _ready():
	var players = get_tree().get_nodes_in_group(PLAYER_NODE_GROUP)
	for player in players:
		var hud = HUD_PLAYER.instantiate()
		playerHudLookup[player] = hud
		hudParent.add_child(hud)
	pass


func add_points(player :CharacterBody3D, amount :int):
	playerHudLookup[player].add_points(amount)
