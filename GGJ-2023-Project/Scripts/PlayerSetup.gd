extends Node

const GAME_SCENE = Constants.GAME_SCENE


# HACK: press something to continue
func _input(_event):
	if Input.is_anything_pressed():
		SceneManager.go_to(GAME_SCENE)
