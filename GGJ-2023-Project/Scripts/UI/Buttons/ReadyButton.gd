extends Button

const NEXT_SCENE = Constants.GAME_SCENE
const SoundType = SfxManager.SoundType


func _pressed():
	SfxManager.enqueue2d(SoundType.MenuConfirm)
	SceneManager.go_to(NEXT_SCENE)
