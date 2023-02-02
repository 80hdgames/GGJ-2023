extends CheckButton

const SoundType = SfxManager.SoundType

func _ready():
	button_pressed = not MusicManager.is_mute()


func _toggled(_button_pressed):	
	MusicManager.set_mute(not button_pressed)


func _pressed():
	SfxManager.enqueue2d(SoundType.MenuConfirm)
