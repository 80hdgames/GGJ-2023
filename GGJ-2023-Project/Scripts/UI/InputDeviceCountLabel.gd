extends Label

const FORMAT_SINGLE = "%s Controller Detected"
const FORMAT_MULTI = "%s Controllers Detected"


func _ready():
	# warning-ignore:return_value_discarded
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	_update_display()
	

func _update_display():
	var device_count = InputManager.get_connected_device_count()
	text = (FORMAT_SINGLE if device_count == 1 else FORMAT_MULTI) % device_count


func _on_joy_connection_changed(_device: int, _connected: bool):
	call_deferred("_update_display")
