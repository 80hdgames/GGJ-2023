extends Button

const NEXT_SCENE = Constants.TITLE_SCREEN_SCENE
const SoundType = SfxManager.SoundType


func _pressed():
	SfxManager.enqueue2d(SoundType.MenuConfirm)
	SceneManager.go_to(NEXT_SCENE)
