extends Control

const SoundType = SfxManager.SoundType

signal settings_open
signal settings_close

@onready var _choices_parent = $VBoxContainer

var _input_start_pos_x
var _vbox_start_pos_x


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	visible = false
	set_process_input(false)
	
	_input_start_pos_x = $InputDevices.get_global_rect().position.x
	_vbox_start_pos_x = $VBoxContainer.get_global_rect().position.x


func _input(event):
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("menu"):
		_on_Back_pressed()
		get_viewport().set_input_as_handled()


func _notification(what):
	match what:
		NOTIFICATION_VISIBILITY_CHANGED:
			if is_visible_in_tree():
				SfxManager.enqueue2d(SoundType.MenuConfirm)
				_choices_parent.get_node("Music").grab_focus()


func _on_Back_pressed():
	visible = false
	set_process_input(false)
	emit_signal("settings_close")


func _on_settings_button_pressed():
	visible = true
	set_process_input(true)
	emit_signal("settings_open")
