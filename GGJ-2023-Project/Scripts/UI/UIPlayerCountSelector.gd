extends HSlider

const SoundType = SfxManager.SoundType

@onready var label :Label = $Label


func _ready():
	_update_players(1)
	grab_focus()
	value_changed.connect(_update_players)


func _update_players(new_value):
	SfxManager.enqueue2d(SoundType.MenuNavigate)
	PlayerManager.set_player_count(int(new_value))
	label.text = ("%s Player" % new_value)

