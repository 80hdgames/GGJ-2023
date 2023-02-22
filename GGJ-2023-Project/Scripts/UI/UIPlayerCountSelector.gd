extends HSlider

const SoundType = SfxManager.SoundType

@onready var label: Label = $Label
@onready var warningLabel: Label = $WarningLabel


func _ready():
	_update_players(1)
	grab_focus()
	value_changed.connect(_update_players)
	
	Input.joy_connection_changed.connect(_on_joy_connection_changed)


func _exit_tree():
	Input.joy_connection_changed.disconnect(_on_joy_connection_changed)


func _on_joy_connection_changed(_device: int, _connected: bool):
	_update_labels()


func _update_players(new_value):
	SfxManager.enqueue2d(SoundType.MenuNavigate)
	PlayerManager.set_player_count(int(new_value))
	_update_labels()


func _update_labels():
	label.text = ("%s Piggies" % value) if value == 1 else ("%s Piggies" % value)
	label.modulate = Color.WHITE if value <= InputManager.get_connected_device_count() + Constants.GAMEPAD_DEVICE_ID_ADD else Color.DARK_RED
	warningLabel.visible = value > InputManager.get_connected_device_count() + Constants.GAMEPAD_DEVICE_ID_ADD
