extends Button

@export_file(".tscn") var playScenePath :String
const SoundType = SfxManager.SoundType


func _ready():
	grab_focus() # PlayButton starts focused for menu navigation


func _pressed():
	SfxManager.enqueue2d(SoundType.MenuConfirm)
	
	# TODO: load game scene
	#GameManager.engage()
	SceneManager.go_to(playScenePath)
