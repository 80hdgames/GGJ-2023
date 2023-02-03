extends Node

@onready var mouseCursor :MouseCursor = MouseCursor.new()
var unlockSources :Array = []
var freeSources :Array = []


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	_update_cursor_state()


func _process(_delta):
	mouseCursor.process()



func exit_tree():
	remove_free_source(self)


func _input(event :InputEvent):
	if event.is_action_pressed("menu"):
		if freeSources.has(self):
			remove_free_source(self)
		else:
			add_free_source(self)
	pass
		
		
func add_unlock_source(source):
	if unlockSources.has(source):
		return
	unlockSources.append(source)
	_update_cursor_state()
	
	
func remove_unlock_source(source):
	if unlockSources.has(source):
		unlockSources.erase(source)
		_update_cursor_state()
	
	
func add_free_source(source):
	if freeSources.has(source):
		return
	freeSources.append(source)
	_update_cursor_state()
	
	
func remove_free_source(source):
	if freeSources.has(source):
		freeSources.erase(source)
		_update_cursor_state()
	
	
func is_cursor_free() -> bool:
	return not freeSources.is_empty()
	
	
func _update_cursor_state():
	if not freeSources.is_empty():
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) # no restriction
	else:
		if not unlockSources.is_empty():
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
			#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		else:
			Input.warp_mouse(get_viewport().size * 0.5)
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#print("Mouse mode now " + str(Input.get_mouse_mode()))
	


class MouseCursor:
	const CURSOR = preload("res://Textures/UI/Cursor.png")
	const CURSOR_CLICK = preload("res://Textures/UI/Cursor_Clicked.png")

	func process():
		if CursorManager.is_cursor_free():
			Input.set_custom_mouse_cursor(null)
		else:
			if Input.is_mouse_button_pressed(1):
				Input.set_custom_mouse_cursor(CURSOR_CLICK)
			else:
				Input.set_custom_mouse_cursor(CURSOR)
