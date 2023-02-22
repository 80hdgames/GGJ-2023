extends Control

@onready var _title_screen_choices = $Control


func _ready():
	CursorManager.add_unlock_source(self)
	
	
func _exit_tree():
	CursorManager.remove_unlock_source(self)

#func _notification(what):
#	match what:
#		NOTIFICATION_VISIBILITY_CHANGED:
#			if is_visible_in_tree():
#				get_node("Control/VBoxContainer/PlayButton").grab_focus()


func _on_ui_settings_settings_open():
	_title_screen_choices.hide()


func _on_ui_settings_settings_close():
	_title_screen_choices.show()
	_title_screen_choices.get_node("VBoxContainer/PlayButton").grab_focus()


func _on_hud_help_help_open():
	_title_screen_choices.hide()


func _on_hud_help_help_close():
	_title_screen_choices.show()
	_title_screen_choices.get_node("VBoxContainer/PlayButton").grab_focus()
