extends Node

@onready var serviceProvider :TimeProvider = TimeProvider.new(self)


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	pass
	

func add_tree_pause_source(source):
	if is_instance_valid(serviceProvider):
		serviceProvider.add_tree_pause_source(source)


func remove_tree_pause_source(source):
	if is_instance_valid(serviceProvider):
		serviceProvider.remove_tree_pause_source(source)


func add_timescale_mod(source, multiplier :float):
	if is_instance_valid(serviceProvider):
		serviceProvider.add_timescale_mod(source, multiplier)


func remove_timescale_mod(source):
	if is_instance_valid(serviceProvider):
		serviceProvider.remove_timescale_mod(source)



class TimeProvider:
	var manager :Node
	var timescaleMods :Dictionary = {}
	var pauseSources :Array = []
	var defaultTimescale :float = 1.0


	func _init(_manager :Node, _defaultTimescsale :float = 1.0):
		manager = _manager
		defaultTimescale = _defaultTimescsale

		_update_timescale()
		pass


	func _toggle_pause():
		if timescaleMods.has(self):
			remove_timescale_mod(self)
		else:
			add_timescale_mod(self, 0)


	func add_tree_pause_source(source):
		if not pauseSources.has(source):
			pauseSources.append(source)
			_update_tree_pause()


	func remove_tree_pause_source(source):
		pauseSources.erase(source)
		_update_tree_pause()


	func add_timescale_mod(source, multiplier :float):
		timescaleMods[source] = multiplier
		_update_timescale()


	func remove_timescale_mod(source):
		if timescaleMods.erase(source):
			_update_timescale()


	func _update_tree_pause():
		if is_instance_valid(manager) and manager.get_tree():
			manager.get_tree().call_deferred("set_pause", not pauseSources.is_empty())


	func _update_timescale():
		var timescale = defaultTimescale
		for key in timescaleMods:
			timescale *= timescaleMods[key]
		Engine.time_scale = timescale
