class_name Game extends Node3D

const MusicType = MusicManager.MusicType

const EXIT_SCENE = Constants.PLAYER_SETUP_SCENE
const PLAYER_PREFAB = preload("res://Scenes/Prefabs/Piggy.tscn")
const PLAYER_START_POSITIONS = Constants.PLAYER_START_POSITIONS

enum GameState {
	Intro,
	Gameplay,
	GameOver,
	Standings,
	WaitForExitInput,
}

var playerInstances :Array = []
var gameState :GameState = GameState.Intro
var _stateTimer :int = 5
@onready var aftermath = $WinningPlaceBlocks 


func _ready():
#	_set_pause_process(true)
	# make a node to store all players in
	var playersNode :Node = Node.new()
	playersNode.process_mode = Node.PROCESS_MODE_PAUSABLE
	playersNode.name = "Players"
	add_child(playersNode)
	move_child(playersNode, 0) # move to top
	# instance desired players
	for i in range(PlayerManager.players):
		var p = PLAYER_PREFAB.instantiate()
		p.name += str(i) # append index on end of name
		playersNode.add_child(p, true)
		playerInstances.append(p)
		p.global_transform.origin = PLAYER_START_POSITIONS[i]
		playersNode.move_child(p, 0) # reverse order of players so player 1 grabs first input
		p.set_player_id(i) # tint the scarf


#func _exit_tree():
#	_set_pause_process(false)


func _input(_event :InputEvent):
	match gameState:
		GameState.WaitForExitInput:
			if _event.is_action_pressed("ui_accept"):
				SceneManager.go_to(EXIT_SCENE)
				set_process_input(false)


func _process(_delta):
	match gameState:
		GameState.Intro:
			if _stateTimer <= 0:
				_swap_state(GameState.Gameplay)
			else:
				_stateTimer -= 1
				
		GameState.GameOver:
			if _stateTimer <= 0:
				_swap_state(GameState.Standings)
			else:
				_stateTimer -= 1
				
		GameState.Standings:
			if _stateTimer <= 0:
				_swap_state(GameState.WaitForExitInput)
			else:
				_stateTimer -= 1


func _swap_state(next :GameState):
	if gameState == next:
		return
	gameState = next
	
	match gameState:
		GameState.Intro:
			return
		GameState.GameOver:
			_stateTimer = 60*3
			return
		GameState.Standings:
			_stateTimer = 60*6
			aftermath.begin()
		GameState.WaitForExitInput:
			pass
		_:	
			_stateTimer = 60
#	_set_pause_process(false)


func game_over():
	_swap_state(GameState.GameOver)


#func position_winners(winners :Array[Node3D]):
#	aftermath.position_winners(winners)


#func _set_pause_process(shouldProcess :bool):
#	if shouldProcess:
#		process_mode = Node.PROCESS_MODE_WHEN_PAUSED
#		TimeManager.add_timescale_mod(self, 0.0)
#	else:
#		process_mode = Node.PROCESS_MODE_INHERIT
#		TimeManager.remove_timescale_mod(self)
