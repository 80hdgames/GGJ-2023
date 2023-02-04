extends Control

const SoundType = SfxManager.SoundType

signal help_open
signal help_close

func _input(event):
	if is_visible_in_tree():
		if event.is_action_pressed("ui_cancel") or\
		event.is_action_pressed("ui_accept"):
			_close()
			


func _notification(what):
	match what:
		NOTIFICATION_VISIBILITY_CHANGED:
			if is_visible_in_tree():
				SfxManager.enqueue2d(SoundType.MenuConfirm)


func _close():
	visible = false
	set_process_input(false)
	get_viewport().set_input_as_handled()
	emit_signal("help_close")


func _on_help_button_pressed():
	visible = true
	set_process_input(true)
	emit_signal("help_open")
