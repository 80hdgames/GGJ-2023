extends Control



func _notification(what):
	match what:
		NOTIFICATION_VISIBILITY_CHANGED:
			if is_visible_in_tree():
				_display_winners()


func _display_winners():
	pass
