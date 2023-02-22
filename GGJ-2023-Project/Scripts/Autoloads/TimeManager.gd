extends Node

@onready var _service_provider: TimeProvider = TimeProvider.new(self)


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	pass
	

func add_tree_pause_source(source):
	if is_instance_valid(_service_provider):
		_service_provider.add_tree_pause_source(source)


func remove_tree_pause_source(source):
	if is_instance_valid(_service_provider):
		_service_provider.remove_tree_pause_source(source)


func add_timescale_mod(source, multiplier: float):
	if is_instance_valid(_service_provider):
		_service_provider.add_timescale_mod(source, multiplier)


func remove_timescale_mod(source):
	if is_instance_valid(_service_provider):
		_service_provider.remove_timescale_mod(source)



class TimeProvider:
	var _manager: Node
	var _timescale_mods: Dictionary = {}
	var _pause_sources: Array = []
	var _default_timescale: float = 1.0


	func _init(_man: Node, _defaultTimescale: float = 1.0):
		_manager = _man
		_default_timescale = _defaultTimescale

		_update_timescale()
		pass


	func _toggle_pause():
		if _timescale_mods.has(self):
			remove_timescale_mod(self)
		else:
			add_timescale_mod(self, 0)


	func add_tree_pause_source(source):
		if not _pause_sources.has(source):
			_pause_sources.append(source)
			_update_tree_pause()


	func remove_tree_pause_source(source):
		_pause_sources.erase(source)
		_update_tree_pause()


	func add_timescale_mod(source, multiplier :float):
		_timescale_mods[source] = multiplier
		_update_timescale()


	func remove_timescale_mod(source):
		if _timescale_mods.erase(source):
			_update_timescale()


	func _update_tree_pause():
		if is_instance_valid(_manager) and _manager.get_tree():
			_manager.get_tree().call_deferred("set_pause", not _pause_sources.is_empty())


	func _update_timescale():
		var timescale = _default_timescale
		for key in _timescale_mods:
			timescale *= _timescale_mods[key]
		Engine.time_scale = timescale
