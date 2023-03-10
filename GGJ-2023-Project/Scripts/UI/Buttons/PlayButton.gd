extends Button

const NEXT_SCENE = Constants.PLAYER_SETUP_SCENE
const SoundType = SfxManager.SoundType


func _ready():
	grab_focus() # PlayButton starts focused for menu navigation


func _pressed():
	SfxManager.enqueue2d(SoundType.MenuConfirm)
	SceneManager.go_to(NEXT_SCENE)
