extends Node

const GAME_SCENE = Constants.GAME_SCENE


func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		SceneManager.go_to(GAME_SCENE)
