extends HSlider

@onready var label :Label = $Label


func _ready():
	grab_focus()
	value_changed.connect(_update_players)


func _update_players(new_value):
	PlayerManager.set_player_count(int(new_value))
	label.text = ("%s Player" % new_value)

