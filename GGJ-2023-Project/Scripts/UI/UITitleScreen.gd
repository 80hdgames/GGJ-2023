extends Control

@onready var titleScreenChoices = $Control


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
	titleScreenChoices.hide()


func _on_ui_settings_settings_close():
	titleScreenChoices.show()
	titleScreenChoices.get_node("VBoxContainer/PlayButton").grab_focus()
