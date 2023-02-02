extends Label

const FORMAT = "Controllers = %s"


func _ready():
	# warning-ignore:return_value_discarded
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	_update_display()
	

func _update_display():
	text = FORMAT % InputManager.get_connected_device_count()


func _on_joy_connection_changed(_device :int, _connected :bool):
	call_deferred("_update_display")
