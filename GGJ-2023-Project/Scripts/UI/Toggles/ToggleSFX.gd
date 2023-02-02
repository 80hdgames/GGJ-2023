extends CheckButton

const SoundType = SfxManager.SoundType


func _ready():
	button_pressed = not SfxManager.is_mute()
	

func _toggled(_button_pressed):	
	SfxManager.set_mute(not button_pressed)
#	var index = AudioServer.get_bus_index("SFX")
#	AudioServer.set_bus_volume_db(index, 1.0 if toggle_mode else 0.0)


func _pressed():
	SfxManager.enqueue2d(SoundType.MenuConfirm)
