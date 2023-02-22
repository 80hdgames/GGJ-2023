extends Node

@onready var _mouse_cursor: MouseCursor = MouseCursor.new()
var _unlock_sources: Array = []
var _free_sources: Array = []


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	_update_cursor_state()


func _process(_delta):
	_mouse_cursor.process()



func exit_tree():
	remove_free_source(self)


func _input(event: InputEvent):
	if event.is_action_pressed("menu"):
		if _free_sources.has(self):
			remove_free_source(self)
		else:
			add_free_source(self)
	pass
		
		
func add_unlock_source(source):
	if _unlock_sources.has(source):
		return
	_unlock_sources.append(source)
	_update_cursor_state()
	
	
func remove_unlock_source(source):
	if _unlock_sources.has(source):
		_unlock_sources.erase(source)
		_update_cursor_state()
	
	
func add_free_source(source):
	if _free_sources.has(source):
		return
	_free_sources.append(source)
	_update_cursor_state()
	
	
func remove_free_source(source):
	if _free_sources.has(source):
		_free_sources.erase(source)
		_update_cursor_state()
	
	
func is_cursor_free() -> bool:
	return not _free_sources.is_empty()
	
	
func _update_cursor_state():
	if not _free_sources.is_empty():
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) # no restriction
	else:
		if not _unlock_sources.is_empty():
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
