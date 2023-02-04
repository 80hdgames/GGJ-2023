extends Button


func _pressed():
	#get_tree().call_group(Constants.PLAYER_NODE_GROUP, "reset_device")
	InputManager.reset_devices()
