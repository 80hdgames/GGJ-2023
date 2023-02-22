extends Node

enum MusicType {
	None,
	Theme,
	PigPen, # player setup
	Gameplay,
	Gameplay_Frantic,
	
	FranticTimeAccent,
}

@onready var _service_provider: MusicProvider = MusicProvider.new(self)
const MUSIC_BUS: String = "Music"


func _ready():
	pass


func _toggle_mute():
	var index: int = AudioServer.get_bus_index(MUSIC_BUS)
	AudioServer.set_bus_mute(index, !AudioServer.is_bus_mute(index))


func set_mute(_value: bool):
	var index: int = AudioServer.get_bus_index(MUSIC_BUS)
	AudioServer.set_bus_mute(index, _value)


func is_mute() -> bool:
	var index: int = AudioServer.get_bus_index(MUSIC_BUS)
	return AudioServer.is_bus_mute(index)


func _process(_delta: float):
	_service_provider.process(_delta)


func enqueue(type: int):
	_service_provider.enqueue(type)
	
	
func push(type: int):
	_service_provider.push(type)
	
	
func pop():
	_service_provider.pop()
	
	
func stop():
	_service_provider.stop()
	
	
func get_current_player() -> AudioStreamPlayer:
	return _service_provider.get_current_player()


class MusicProvider:
	var _manager: Node
	var _last_track_index: int = 0
	var _num_players: int = 1
	var bus: String = "Music"
	var _last_playback_position: float = 0.0

	var _available: Array = []  # The _available players.
	var _queue: Array = []  # The _queue of clip sets to play by path.
	var _playing: Dictionary = {} # <ClipSet, player>
	var _pushed: Array = []

	# range of delays after a track finishes
	const DELAY_VARIATION = Vector2(5.0, 45.0)
	const MUSIC_PATH_FORMAT = "res://Audio/Music/ClipSets/%s.tres"


	func _init(_man: Node):
		_manager = _man
		
		# Create the pool of AudioStreamPlayer nodes.
		for i in _num_players:
			var p = AudioStreamPlayer.new()
			_manager.add_child(p)
			p.name = "Music " + str(i)
			#p.volume_db = 0 # for now
			_available.append(p)
			p.finished.connect(_on_stream_finished.bind(p))
			p.bus = bus


	func _on_pushed_stream_finished(_player):
		_player.stop()
		_player.queue_free()
		_pushed.erase(_player)


	func _on_stream_finished(_player):
		if not _pushed.is_empty() and _pushed[_pushed.size() - 1] == _player:
			pop()
		# When finished _playing a stream, make the player _available again.
		#_available.append(player)
		pass # loop indefinitely mwhahaha!


	func push(type: int):
		_last_playback_position = _available[0].get_playback_position()
		_available[0].stop()
		var index = MusicType.values().find(type)
		var path = MUSIC_PATH_FORMAT % MusicType.keys()[index]
		if not ResourceLoader.exists(path):
			return
		var clip_set: AudioClipSet = load(path)
		if clip_set:
			var p = AudioStreamPlayer.new()
			_manager.add_child(p)
			p.name = "Pushed Music " + str(_pushed.size()+1)
			_pushed.append(p)
			p.finished.connect(_on_pushed_stream_finished.bind(p))
			p.bus = bus
			
			var stream: AudioStreamOggVorbis = clip_set.get_clip(_last_track_index)
			stream.loop = false
			p.stream = stream
			p.volume_db = clip_set.get_volume_db()
			p.pitch_scale = clip_set.get_pitch()
			p.play()


	func pop():
		var popped = _pushed.pop_back()
		if not popped:
			return
		popped.stop()
		popped.queue_free()
		# don't resume?
#		if _pushed.empty() and not _playing.empty():
#			_playing[0].play(_last_playback_position)


	func enqueue(type: int):
		var index: int = MusicType.values().find(type)
		var path: String = MUSIC_PATH_FORMAT % MusicType.keys()[index]
		#print("Enqueueing " + path)
		#_queue.append(PlayInfo.new(path, pos))
		#if not _queue.has(path):
		_queue.append(path)


	func stop():
		for key in _pushed:
			key.stop()
			key.queue_free()
		_pushed.clear()
			
		for key in _playing:
			key.stop()
			_available.append(key)
			# warning-ignore:return_value_discarded
			_playing.erase(key)
		#while (_playing.size() > 0):
		#	playing_tracks.erase(_playing[0].stream)
		#	_playing[0].stop()
		#	_available.append( _playing.pop_front() )


	func process(_delta: float):
		# Play a queued sound if any players are _available.
		if not _queue.is_empty() and _pushed.is_empty():
			var path: String = _queue.pop_front()
			if not ResourceLoader.exists(path):
				return
			var clip_set: AudioClipSet = load(path)
			if clip_set:
				if _playing.values().has(clip_set):
					return
				_last_track_index = clip_set.get_random_clip_index()
				var stream: AudioStreamOggVorbis = clip_set.get_clip(_last_track_index)
				stream.loop = true
				_available[0].stream = stream
				_available[0].volume_db = clip_set.get_volume_db()
				_available[0].pitch_scale = clip_set.get_pitch()
				_playing[ _available[0] ] = clip_set
				_available[0].play()
				#_available.pop_front()


	func get_current_player() -> AudioStreamPlayer:
		for key in _playing:
			return key
		return null
