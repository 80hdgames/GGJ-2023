class_name HUDGame extends Control

const SoundType = SfxManager.SoundType
const PLAYER_NODE_GROUP = Constants.PLAYER_NODE_GROUP
const HUD_PLAYER = preload("res://Scenes/Prefabs/UI/HUDPlayer.tscn")

var playerHudLookup :Dictionary = {}
@onready var hudParent = $Margin/HBoxContainer
@onready var gameOverLabel = $Margin/GameOverLabel


func _ready():
	gameOverLabel.hide()
	
	var players :Array = get_tree().get_nodes_in_group(PLAYER_NODE_GROUP)
	for player in players:
		assert(player is CharacterBody3D)
		var hud = HUD_PLAYER.instantiate()
		playerHudLookup[player] = hud
		hudParent.add_child(hud, true)
		assert(hud is HUDPlayer)
	pass


func add_points(player :CharacterBody3D, amount :int):
	assert(playerHudLookup.has(player))
	playerHudLookup[player].add_points(amount)


func game_over():
	SfxManager.enqueue2d(SoundType.GameOver)
	print("GAME OVER!")
	gameOverLabel.self_modulate = Color.RED
	gameOverLabel.show()
	var tween = create_tween()
	tween.tween_property(gameOverLabel, "self_modulate", Color.WHITE, 0.5)
