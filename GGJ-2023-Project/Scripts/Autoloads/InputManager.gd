extends Node

# warning-ignore:unused_signal
#signal reset_devices
signal devices_changed

var _device_lookup :Dictionary = {}

const SoundType = SfxManager.SoundType
const GAMEPAD_DEVICE_ID_ADD = Constants.GAMEPAD_DEVICE_ID_ADD


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	# warning-ignore:return_value_discarded
	Input.joy_connection_changed.connect(_on_joy_connection_changed)


func _on_joy_connection_changed(device: int, connected: bool):
	if connected:
		SfxManager.enqueue2d(SoundType.MenuNavigate)
	else:
		device = device + GAMEPAD_DEVICE_ID_ADD # HACK: desktop shouldn't call this right?
		if !connected and is_device_in_use(device):
			SfxManager.enqueue2d(SoundType.DeviceLost)
			expunge_device(device)


func reset_devices():
	SfxManager.enqueue2d(SoundType.DeviceLost)
	for key in _device_lookup:
		_device_lookup[key].reset_device()
		_device_lookup[key].tree_exiting.disconnect(_on_tree_exiting)
	_device_lookup.clear()
	emit_signal("devices_changed")


func register_device(id: int, instance: Node) -> bool:
	if not _device_lookup.has(id):
		SfxManager.enqueue2d(SoundType.DeviceAssigned)
		_device_lookup[id] = instance
		# warning-ignore:return_value_discarded
		instance.tree_exiting.connect(_on_tree_exiting.bind(instance))
		emit_signal("devices_changed")
		return true
	else:
		return false
	
	
func expunge_device(id: int):
	if _device_lookup.has(id) and is_instance_valid(_device_lookup[id]):
		_device_lookup[id].reset_device()
		_device_lookup[id].tree_exiting.disconnect(_on_tree_exiting)
	# warning-ignore:return_value_discarded
	_device_lookup.erase(id)
	emit_signal("devices_changed")
	
	
func is_device_in_use(id: int) -> bool:
	return _device_lookup.has(id)
	
	
func get_instance_of_device(id: int):
	return _device_lookup[id]


func get_device_of_instance(instance) -> int:
	for key in _device_lookup:
		if _device_lookup[key] == instance:
			return key
	return -1


func get_device_display_of_instance(instance) -> String:
	var i :int = get_device_of_instance(instance)
	if i < GAMEPAD_DEVICE_ID_ADD and i >= 0:
		return "Desktop %s\n(%s)" % [(i + 1), "WASD" if i == 0 else "Arrows"]
	elif i < 0:
		return "..."
	else:
		var joys: Array = Input.get_connected_joypads()
		var id = joys[i-GAMEPAD_DEVICE_ID_ADD]
		var result: String = "(%s) %s" % [id, Input.get_joy_name(id)]
		return result


# clear device registration when corresponding instance is removed from the tree
func _on_tree_exiting(node: Node):
	var cleanup: Array = []
	for key in _device_lookup:
		if _device_lookup[key] == node:
			cleanup.append(key)
			
	for id in cleanup:
		expunge_device(id)


func get_connected_device_count() -> int:
	return Input.get_connected_joypads().size()


# --- RUMBLE ---

func rumble(id: int, amount: float):
	Input.start_joy_vibration(id, amount, amount, 0)


func rumble_all(amount: float):
	for id in Input.get_connected_joypads():
		rumble(id, amount)
	
	
func stop_rumble(id: int):
	Input.stop_joy_vibration(id)
	

func stop_rumbles():
	for id in Input.get_connected_joypads():
		stop_rumble(id)

# --- --- ---
