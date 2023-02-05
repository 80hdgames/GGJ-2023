class_name HUDGame extends Control

const SoundType = SfxManager.SoundType
const PLAYER_NODE_GROUP = Constants.PLAYER_NODE_GROUP
const PLAYER_COLORS = Constants.PLAYER_COLORS
const PLAYER_NAMES = Constants.PLAYER_NAMES
const HUD_PLAYER = preload("res://Scenes/Prefabs/UI/HUDPlayer.tscn")

var playerHudLookup :Dictionary = {}
@onready var hudParent = $Margin/HBoxContainer
@onready var hudGameOver = $Margin/HUDGameOver
@onready var hudTimer = $Margin/HUDTimer


func _ready():
	hudGameOver.hide()
	call_deferred("_setup_huds")
	pass


func _setup_huds():
	var players :Array = get_tree().get_nodes_in_group(PLAYER_NODE_GROUP)
	players.reverse() # flip order due to player instances needing to be sorted backwards (bottom node snags input first)
	var i :int = 0
	for player in players:
		assert(player is CharacterBody3D)
		var hud = HUD_PLAYER.instantiate()
		hud.set_color(PLAYER_COLORS[wrapi(i, 0, PLAYER_COLORS.size())])
		hud.set_name(PLAYER_NAMES[wrapi(i, 0, PLAYER_NAMES.size())])
		playerHudLookup[player] = hud
		hudParent.add_child(hud, true)
		assert(hud is HUDPlayer)
		i += 1


func add_points(player :CharacterBody3D, amount :int, timeBonus :float = 0.0):
	assert(playerHudLookup.has(player))
	hudTimer.add_time(timeBonus)
	playerHudLookup[player].add_points(amount)


func game_over():
	get_tree().call_group(PLAYER_NODE_GROUP, "game_over")
	
	# HACK: cannot pause anymore
	$UIPause.queue_free()
	
	assert(get_tree().current_scene is Game)
	get_tree().current_scene.game_over()
	MusicManager.stop()
	SfxManager.enqueue2d(SoundType.GameOver)
	print("GAME OVER!")
	hudGameOver.modulate = Color.RED
	hudGameOver.display_results([get_winning_player_instance()])
	var gameOverTween = create_tween()
	gameOverTween.tween_property(hudGameOver, "modulate", Color.WHITE, 0.5)
	
	var winningPlayers :Array[Node3D] = get_winning_players()
	PlayerManager.winners = winningPlayers
	
	for key in winningPlayers:
		key._jump() # jump for joy
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_ELASTIC)
		tween.set_parallel(true)
		tween.tween_property(playerHudLookup[key], "position:y", -240.0, 3.0)
		tween.tween_property(playerHudLookup[key], "scale", Vector2.ONE * 1.1, 3.0)
		tween.play()
	
	# hide the loser's huds
#	for key in playerHudLookup:
#		playerHudLookup[key].visible = winningHuds.has(playerHudLookup[key])


func get_time_left() -> float:
	return hudTimer.get_time_left()


func get_winning_player_huds() -> Array:
	var winners :Array = []
	var amountToBeat :int = -1
	for key in playerHudLookup:
		if amountToBeat < playerHudLookup[key].get_points():
			winners.clear()
			winners.append(playerHudLookup[key])
			amountToBeat = playerHudLookup[key].get_points()
		elif amountToBeat == playerHudLookup[key].get_points():
			winners.append(playerHudLookup[key])
	return winners
	
	
func get_winning_players() -> Array[Node3D]:
	var winners :Array[Node3D] = []
	var amountToBeat :int = -1
	for key in playerHudLookup:
		if amountToBeat < playerHudLookup[key].get_points():
			winners.clear()
			winners.append(key)
			amountToBeat = playerHudLookup[key].get_points()
		elif amountToBeat == playerHudLookup[key].get_points():
			winners.append(key)
	return winners


func get_winning_player_instance() -> Node3D:
	var winner = null
	var amountToBeat :int = -1
	for key in playerHudLookup:
		if amountToBeat < playerHudLookup[key].get_points():
			winner = key # cache the player
			amountToBeat = playerHudLookup[key].get_points()
		elif amountToBeat == playerHudLookup[key].get_points():
			winner = null
			amountToBeat = playerHudLookup[key].get_points()
	return winner
