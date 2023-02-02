extends HSlider

const SoundType = SfxManager.SoundType

@onready var label :Label = $Label
@onready var warningLabel :Label = $WarningLabel


func _ready():
	_update_players(1)
	grab_focus()
	value_changed.connect(_update_players)


func _update_players(new_value):
	SfxManager.enqueue2d(SoundType.MenuNavigate)
	PlayerManager.set_player_count(int(new_value))
	label.text = ("%s Player" % new_value)
	label.modulate = Color.WHITE if new_value <= InputManager.get_connected_device_count() + Constants.GAMEPAD_DEVICE_ID_ADD else Color.DARK_RED
	warningLabel.visible = new_value > InputManager.get_connected_device_count() + Constants.GAMEPAD_DEVICE_ID_ADD
