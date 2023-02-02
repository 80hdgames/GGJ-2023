extends CheckButton

const SoundType = SfxManager.SoundType


func _ready():
#	button_pressed = OS.window_fullscreen
	pass
	
	

func _toggled(_button_pressed):
	#OS.set_window_fullscreen(pressed)
#	OS.call_deferred("set_window_fullscreen", button_pressed)
#	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)  
	pass


func _pressed():
	SfxManager.enqueue2d(SoundType.MenuConfirm)
	pass
