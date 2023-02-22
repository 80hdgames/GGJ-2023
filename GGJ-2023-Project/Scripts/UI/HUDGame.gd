class_name HUDGame extends Control

const SoundType = SfxManager.SoundType
const PLAYER_NODE_GROUP = Constants.PLAYER_NODE_GROUP
const PLAYER_COLORS = Constants.PLAYER_COLORS
const PLAYER_NAMES = Constants.PLAYER_NAMES
const HUD_PLAYER = preload("res://Scenes/Prefabs/UI/HUDPlayer.tscn")

var _player_hud_lookup: Dictionary = {}
@onready var _hud_parent = $Margin/HBoxContainer
@onready var _hud_game_over = $Margin/HUDGameOver
@onready var _hud_timer = $Margin/HUDTimer


func _ready():
	_hud_game_over.hide()
	call_deferred("_setup_huds")
	pass


func _setup_huds():
	var players: Array = get_tree().get_nodes_in_group(PLAYER_NODE_GROUP)
	players.reverse() # flip order due to player instances needing to be sorted backwards (bottom node snags input first)
	var i: int = 0
	for player in players:
		assert(player is CharacterBody3D)
		var hud = HUD_PLAYER.instantiate() as HUDPlayer
		hud.set_color(PLAYER_COLORS[wrapi(i, 0, PLAYER_COLORS.size())])
		hud.set_name(PLAYER_NAMES[wrapi(i, 0, PLAYER_NAMES.size())])
		_player_hud_lookup[player] = hud
		_hud_parent.add_child(hud, true)
		i += 1


func add_points(player: CharacterBody3D, amount: int, time_bonus: float = 0.0):
	assert(_player_hud_lookup.has(player))
	_hud_timer.add_time(time_bonus)
	_player_hud_lookup[player].add_points(amount)


func game_over():
	get_tree().call_group(PLAYER_NODE_GROUP, "game_over")
	
	# HACK: cannot pause anymore
	$UIPause.queue_free()
	
	assert(get_tree().current_scene is Game)
	get_tree().current_scene.game_over()
	MusicManager.stop()
	SfxManager.enqueue2d(SoundType.GameOver)
	print("GAME OVER!")
	_hud_game_over.modulate = Color.RED
	_hud_game_over.display_results([get_winning_player_instance()])
	var game_over_tween = create_tween()
	game_over_tween.tween_property(_hud_game_over, "modulate", Color.WHITE, 0.5)
	
	var winning_players :Array[Node3D] = get_winning_players()
	PlayerManager.winners = winning_players
	
	for key in winning_players:
		key.jump() # jump for joy
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_ELASTIC)
		tween.set_parallel(true)
		tween.tween_property(_player_hud_lookup[key], "position:y", -240.0, 3.0)
		tween.tween_property(_player_hud_lookup[key], "scale", Vector2.ONE * 1.1, 3.0)
		tween.play()
	
	# hide the loser's huds
#	for key in _player_hud_lookup:
#		_player_hud_lookup[key].visible = winningHuds.has(_player_hud_lookup[key])


func get_time_left() -> float:
	return _hud_timer.get_time_left()


func get_winning_player_huds() -> Array[HUDPlayer]:
	var winners: Array[HUDPlayer] = []
	var amount_to_beat: int = -1
	for key in _player_hud_lookup:
		if amount_to_beat < _player_hud_lookup[key].get_points():
			winners.clear()
			winners.append(_player_hud_lookup[key])
			amount_to_beat = _player_hud_lookup[key].get_points()
		elif amount_to_beat == _player_hud_lookup[key].get_points():
			winners.append(_player_hud_lookup[key])
	return winners
	
	
func get_winning_players() -> Array[Node3D]:
	var winners: Array[Node3D] = []
	var amount_to_beat: int = -1
	for key in _player_hud_lookup:
		if amount_to_beat < _player_hud_lookup[key].get_points():
			winners.clear()
			winners.append(key)
			amount_to_beat = _player_hud_lookup[key].get_points()
		elif amount_to_beat == _player_hud_lookup[key].get_points():
			winners.append(key)
	return winners


func get_winning_player_instance() -> Node3D:
	var winner = null
	var amount_to_beat: int = -1
	for key in _player_hud_lookup:
		if amount_to_beat < _player_hud_lookup[key].get_points():
			winner = key # cache the player
			amount_to_beat = _player_hud_lookup[key].get_points()
		elif amount_to_beat == _player_hud_lookup[key].get_points():
			winner = null
			amount_to_beat = _player_hud_lookup[key].get_points()
	return winner
