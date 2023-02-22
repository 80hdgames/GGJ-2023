extends CheckButton

const SoundType = SfxManager.SoundType


func _ready():
	button_pressed = DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_WINDOWED
	toggled.connect(_custom_toggle)
	
	

func _custom_toggle(_button_pressed):
	var window_mode = DisplayServer.window_get_mode()
	match window_mode:
		DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		_:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _pressed():
	SfxManager.enqueue2d(SoundType.MenuConfirm)
	pass
