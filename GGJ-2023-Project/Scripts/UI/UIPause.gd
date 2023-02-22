extends Control

@onready var choices = $Control/VBoxContainer


func _ready():
	pass
	
	
func _unhandled_input(_event: InputEvent):
	if _event.is_action_pressed("menu"):
		visible = !visible
		get_viewport().set_input_as_handled()
	
	
func _exit_tree():
	CursorManager.remove_unlock_source(self)
	TimeManager.remove_tree_pause_source(self)


func _notification(what):
	match what:
		NOTIFICATION_VISIBILITY_CHANGED:
			if is_visible_in_tree():
				_on_ui_settings_settings_close() # HACK: grab focus of first button
				TimeManager.add_tree_pause_source(self)
				CursorManager.add_unlock_source(self)
				
			else:
				TimeManager.remove_tree_pause_source(self)
				CursorManager.remove_unlock_source(self)


func _on_ui_settings_settings_open():
	choices.hide()


func _on_ui_settings_settings_close():
	choices.show()
	choices.get_node("PlayButton").grab_focus()


func _on_play_button_pressed():
	hide()
