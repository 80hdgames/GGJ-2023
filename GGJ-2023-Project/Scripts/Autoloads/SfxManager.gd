extends Node

enum SoundType {
	None,
	
	MenuNavigate,
	MenuConfirm,
	MenuCancel,
	
	DeviceAssigned,
	DeviceLost,
	
	GameOver,
	Collect,
	Boost,
	
	PigGrunt,
	PigSqueal,
	Fart,
	
	DirtScuffle,
	Footstep,
	Grow
}

const SFX_PATH_FORMAT = "res://Audio/SFX/ClipSets/%s.tres"
const CLIP_SETS_DIRECTORY = "res://Audio/SFX/ClipSets"

@onready var _service_provider = SfxProvider.new(self)


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	# warning-ignore:return_value_discarded
	get_viewport().gui_focus_changed.connect(_on_gui_focus_change)


func _on_gui_focus_change(_arg: Control):
#	if not SceneManager.is_ready_to_load():
#		return
		
	if _arg.is_visible_in_tree():
		enqueue2d(SoundType.MenuNavigate)


func set_mute(_value: bool):
	var index: int = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_mute(index, _value)


func _toggle_mute():
	var index: int = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_mute(index, !AudioServer.is_bus_mute(index))
	
	
func is_mute() -> bool:
	var index: int = AudioServer.get_bus_index("SFX")
	return AudioServer.is_bus_mute(index)


func _process(delta: float):
	_service_provider.process(delta)
	
	
func enqueue2d(type: int, pitchScale: float = 1.0):
	_service_provider.enqueue2d(type, pitchScale)


func enqueue3d(type: int, pos: Vector3, pitchScale: float = 1.0):
	_service_provider.enqueue(type, get_viewport().get_camera_3d().unproject_position(pos), pitchScale)


func enqueue(type: int, pos: Vector2, pitchScale: float = 1.0):
	_service_provider.enqueue(type, pos, pitchScale)


func get_clip_set(id: String):
	return _service_provider.get_clip_set_by_path(SFX_PATH_FORMAT % id)


func get_clip_set_by_path(path: String):
	return _service_provider.get_clip_set_by_path(path)


class SfxProvider:
	enum PlayerType {
		Positional2D = 0,
		Mono,
	}

	var _manager: Node
	# <type, array>
	var _available: Dictionary = {}  # The _available players.
	# <type, array>
	var _queue: Dictionary = {}  # The _queue of sounds to play via PlayInfos.

	var _clip_set_lookup: Dictionary = {}

	const NUM_PLAYERS = 16
	const MAX_DISTANCE = 2000.0
	const BUS = "SFX"
	const COMBINE_WINDOW = 0.5
	const COMBINE_WINDOW_MS = COMBINE_WINDOW * 1000 # in ms


	func _init(_man: Node):
		_manager = _man
		_populate_lookup()
		# Create the pool of AudioStreamPlayer nodes.
		for pType in PlayerType.values():
			var players: Array = []
			for i in NUM_PLAYERS:
				var p
				match pType:
					PlayerType.Mono:
						p = AudioStreamPlayer.new()
						p.name = "Sfx Mono " + str(i)
					_:
						p = AudioStreamPlayer2D.new()
						p.attenuation = 1.0
						p.max_distance = MAX_DISTANCE
						p.name = "Sfx 2D " + str(i)
				_manager.add_child(p)
				players.append(p)
				var _c = p.finished.connect(_on_stream_finished.bind(pType, p))
				p.bus = BUS
			_available[pType] = players
			_queue[pType] = []
			
			
	func _populate_lookup():
		print("\n")
		print("Loading SFX Clip Sets...")
		_clip_set_lookup.clear()
		var dir = DirAccess.open(CLIP_SETS_DIRECTORY)
		if dir != null:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if not dir.current_is_dir():
					var path = CLIP_SETS_DIRECTORY + "/" + file_name
					_clip_set_lookup[path] = load(path)
				file_name = dir.get_next()
			print("Successfully Loaded %s SFX Clip Sets\n" % _clip_set_lookup.size())
		else:
			print("An error occurred when trying to access the path.")


	func get_clip_set_by_path(path: String) -> AudioClipSet:
		if not _clip_set_lookup.has(path):
			push_warning("Audio Clip Set at %s does not exist!" % path)
		return _clip_set_lookup.get(path)


	func _on_stream_finished(playerType: int, player):
		# When finished _playing a stream, make the player _available again.
		_available.get(playerType).append(player)


	func enqueue2d(type: int, pitchScale: float):
		if type == SoundType.None:
			return
		var index = SoundType.values().find(type)
		var path = SFX_PATH_FORMAT % SoundType.keys()[index]
		#print("Enqueueing 2D SFX " + path)
		if !_queue.has(PlayerType.Mono):
			printerr("No Mono player type _queue _available!?")
			return
		# merge frequent occurances of same sound type
		if _queue.get(PlayerType.Mono).size() > 0:
			var last = _queue.get(PlayerType.Mono).back()
			if abs(Time.get_ticks_msec() - last.time) <= COMBINE_WINDOW_MS and last.path == path:
				#print("Ignoring " + path + " matches last recent sound type")
				return
		_queue.get(PlayerType.Mono).append(PlayInfo.new(path, Vector2.ZERO, pitchScale))


	func enqueue(type: int, pos: Vector2, pitchScale: float):
		if type == SoundType.None:
			return
		var index = SoundType.values().find(type)
		var path = SFX_PATH_FORMAT % SoundType.keys()[index]
		#print("Enqueueing 3D SFX " + path)
		
		# For some reason this is null!?
		#var targetQueue = _queue.get(PlayerType.Positional2D)
		if !_queue.has(PlayerType.Positional2D):
			printerr("No Positional2D player type _queue _available!?")
			return
		# merge frequent occurances of same sound type
		if _queue.get(PlayerType.Positional2D).size() > 0:
			var last = _queue.get(PlayerType.Positional2D).back()
			if last.path == path and abs(Time.get_ticks_msec() - last.time) <= COMBINE_WINDOW_MS:
				last.position = last.position.move_toward(pos, 0.5) # average of positions
				return
		_queue.get(PlayerType.Positional2D).append(PlayInfo.new(path, pos, pitchScale))


	func process(_delta: float):
		for key in _queue:
			_process_queue(key)
		
		
	func _process_queue(key):
		var array = _queue.get(key)
		# Play a queued sound if any players are _available.
		if not array.is_empty() and not _available.get(key).is_empty():
			var play_info = array.pop_front()
			if not ResourceLoader.exists(play_info.path):
				return
			var clip_set = load(play_info.path)
			if clip_set:
				match key:
					PlayerType.Positional2D:
						_available[key][0].attenuation = 1.0
						_available[key][0].max_distance = MAX_DISTANCE
						_available[key][0].global_transform.origin = play_info.position
						
						# duplicate code :P
						_available[key][0].stream = clip_set.get_random_clip()
						_available[key][0].pitch_scale = clip_set.get_pitch() * play_info.pitch
						_available[key][0].volume_db = clip_set.get_volume_db()
						_available[key][0].play()
					_:
						_available[key][0].stream = clip_set.get_random_clip()
						_available[key][0].pitch_scale = clip_set.get_pitch() * play_info.pitch
						_available[key][0].volume_db = clip_set.get_volume_db()
						_available[key][0].play()
			_available.get(key).pop_front()



	class PlayInfo:
		func _init(_path: String, _position = Vector2.ZERO, _pitch: float = 1.0):
			position = _position
			path = _path
			pitch = _pitch
			time = Time.get_ticks_msec()
		
		var time: int
		var pitch: float
		var position: Vector2
		var path: String
