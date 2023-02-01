extends Node

const GAME_SCENE = Constants.GAME_SCENE
const TITLE_SCREEN_SCENE = Constants.TITLE_SCREEN_SCENE


func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		SceneManager.go_to(GAME_SCENE)
	elif event.is_action_pressed("ui_cancel"):
		SceneManager.go_to(TITLE_SCREEN_SCENE)
