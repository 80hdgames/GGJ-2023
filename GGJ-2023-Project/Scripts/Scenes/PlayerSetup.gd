extends Node

const GAME_SCENE = Constants.GAME_SCENE
const TITLE_SCREEN_SCENE = Constants.TITLE_SCREEN_SCENE
const PLAYER_COLORS = Constants.PLAYER_COLORS

@onready var piggyParent = $Piggies


func _ready():
	CursorManager.add_unlock_source(self)
	PlayerManager.player_count_changed.connect(_on_player_count_changed)
	
	for i in range(piggyParent.get_child_count()):
		piggyParent.get_child(i).set_color(PLAYER_COLORS[wrapi(i, 0, PLAYER_COLORS.size())])
	_on_player_count_changed() # update initial display


func _exit_tree():
	CursorManager.remove_unlock_source(self)
	PlayerManager.player_count_changed.disconnect(_on_player_count_changed)


func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		SceneManager.go_to(GAME_SCENE)
	elif event.is_action_pressed("ui_cancel"):
		SceneManager.go_to(TITLE_SCREEN_SCENE)


func _on_player_count_changed():
	for i in range(piggyParent.get_child_count()):
		piggyParent.get_child(i).visible = i < PlayerManager.players
