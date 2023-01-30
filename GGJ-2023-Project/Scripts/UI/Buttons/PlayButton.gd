extends Button

const SoundType = SfxManager.SoundType


func _ready():
	grab_focus() # PlayButton starts focused for menu navigation


func _pressed():
	SfxManager.enqueue2d(SoundType.MenuConfirm)
	
	# TODO: load game scene
	#GameManager.engage()
