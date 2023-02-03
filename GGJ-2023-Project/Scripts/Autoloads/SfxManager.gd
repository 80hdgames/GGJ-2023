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

@onready var serviceProvider = SfxProvider.new(self)


func _ready():
	# warning-ignore:return_value_discarded
	get_viewport().gui_focus_changed.connect(_on_gui_focus_change)


func _on_gui_focus_change(_arg :Control):
#	if not SceneManager.is_ready_to_load():
#		return
		
	if _arg.is_visible_in_tree():
		enqueue2d(SoundType.MenuNavigate)


func set_mute(_value :bool):
	var index :int = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_mute(index, _value)


func _toggle_mute():
	var index :int = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_mute(index, !AudioServer.is_bus_mute(index))
	
	
func is_mute() -> bool:
	var index :int = AudioServer.get_bus_index("SFX")
	return AudioServer.is_bus_mute(index)


func _process(delta :float):
	serviceProvider.process(delta)
	
	
func enqueue2d(type :int, pitchScale :float = 1.0):
	serviceProvider.enqueue2d(type, pitchScale)


func enqueue3d(type :int, pos :Vector3, pitchScale :float = 1.0):
	serviceProvider.enqueue(type, get_viewport().get_camera_3d().unproject_position(pos), pitchScale)


func enqueue(type :int, pos :Vector2, pitchScale :float = 1.0):
	serviceProvider.enqueue(type, pos, pitchScale)


func get_clip_set(id :String):
	return serviceProvider.get_clip_set_by_path(SFX_PATH_FORMAT % id)


func get_clip_set_by_path(path :String):
	return serviceProvider.get_clip_set_by_path(path)


class SfxProvider:
	enum PlayerType {
		Positional2D = 0,
		Mono,
	}

	var manager :Node
	# <type, array>
	var available :Dictionary = {}  # The available players.
	# <type, array>
	var queue :Dictionary = {}  # The queue of sounds to play via PlayInfos.

	var clipSetLookup :Dictionary = {}

	const NUM_PLAYERS = 16
	const MAX_DISTANCE = 2000.0
	const BUS = "SFX"
	const COMBINE_WINDOW = 0.5
	const COMBINE_WINDOW_MS = COMBINE_WINDOW * 1000 # in ms


	func _init(_manager :Node):
		manager = _manager
		_populate_lookup()
		# Create the pool of AudioStreamPlayer nodes.
		for pType in PlayerType.values():
			var players :Array = []
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
				manager.add_child(p)
				players.append(p)
				var _c = p.finished.connect(_on_stream_finished.bind(pType, p))
				p.bus = BUS
			available[pType] = players
			queue[pType] = []
			
			
	func _populate_lookup():
		print("\n")
		print("Loading SFX Clip Sets...")
		clipSetLookup.clear()
		var dir = DirAccess.open(CLIP_SETS_DIRECTORY)
		if dir != null:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if not dir.current_is_dir():
					var path = CLIP_SETS_DIRECTORY + "/" + file_name
					clipSetLookup[path] = load(path)
				file_name = dir.get_next()
			print("Successfully Loaded %s SFX Clip Sets\n" % clipSetLookup.size())
		else:
			print("An error occurred when trying to access the path.")


	func get_clip_set_by_path(path :String) -> AudioClipSet:
		if not clipSetLookup.has(path):
			push_warning("Audio Clip Set at %s does not exist!" % path)
		return clipSetLookup.get(path)


	func _on_stream_finished(playerType :int, player):
		# When finished playing a stream, make the player available again.
		available.get(playerType).append(player)


	func enqueue2d(type :int, pitchScale :float):
		if type == SoundType.None:
			return
		var index = SoundType.values().find(type)
		var path = SFX_PATH_FORMAT % SoundType.keys()[index]
		#print("Enqueueing 2D SFX " + path)
		if !queue.has(PlayerType.Mono):
			printerr("No Mono player type queue available!?")
			return
		# merge frequent occurances of same sound type
		if queue.get(PlayerType.Mono).size() > 0:
			var last = queue.get(PlayerType.Mono).back()
			if abs(Time.get_ticks_msec() - last.time) <= COMBINE_WINDOW_MS and last.path == path:
				#print("Ignoring " + path + " matches last recent sound type")
				return
		queue.get(PlayerType.Mono).append(PlayInfo.new(path, Vector2.ZERO, pitchScale))


	func enqueue(type :int, pos :Vector2, pitchScale :float):
		if type == SoundType.None:
			return
		var index = SoundType.values().find(type)
		var path = SFX_PATH_FORMAT % SoundType.keys()[index]
		#print("Enqueueing 3D SFX " + path)
		
		# For some reason this is null!?
		#var targetQueue = queue.get(PlayerType.Positional2D)
		if !queue.has(PlayerType.Positional2D):
			printerr("No Positional2D player type queue available!?")
			return
		# merge frequent occurances of same sound type
		if queue.get(PlayerType.Positional2D).size() > 0:
			var last = queue.get(PlayerType.Positional2D).back()
			if last.path == path and abs(Time.get_ticks_msec() - last.time) <= COMBINE_WINDOW_MS:
				last.position = last.position.move_toward(pos, 0.5) # average of positions
				return
		queue.get(PlayerType.Positional2D).append(PlayInfo.new(path, pos, pitchScale))


	func process(_delta :float):
		for key in queue:
			_process_queue(key)
		
		
	func _process_queue(key):
		var array = queue.get(key)
		# Play a queued sound if any players are available.
		if not array.is_empty() and not available.get(key).is_empty():
			var playInfo = array.pop_front()
			if not ResourceLoader.exists(playInfo.path):
				return
			var clipSet = load(playInfo.path)
			if clipSet:
				match key:
					PlayerType.Positional2D:
						available[key][0].attenuation = 1.0
						available[key][0].max_distance = MAX_DISTANCE
						available[key][0].global_transform.origin = playInfo.position
						
						# duplicate code :P
						available[key][0].stream = clipSet.get_random_clip()
						available[key][0].pitch_scale = clipSet.get_pitch() * playInfo.pitch
						available[key][0].volume_db = clipSet.get_volume_db()
						available[key][0].play()
					_:
						available[key][0].stream = clipSet.get_random_clip()
						available[key][0].pitch_scale = clipSet.get_pitch() * playInfo.pitch
						available[key][0].volume_db = clipSet.get_volume_db()
						available[key][0].play()
			available.get(key).pop_front()



	class PlayInfo:
		func _init(_path :String, _position = Vector2.ZERO, _pitch :float = 1.0):
			position = _position
			path = _path
			pitch = _pitch
			time = Time.get_ticks_msec()
		
		var time :int
		var pitch :float
		var position :Vector2
		var path :String
