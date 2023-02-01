class_name AudioClipSet extends Resource

@export var clips :Array[AudioStream] = []
#@export var priority :int = 0
@export_range(0.0, 2.0) var volumeMultiplier :float = 1.0
@export_range(0.0, 3.0) var pitchMultiplier :float = 1.0
@export_range(0.0, 3.0) var pitchRandomness :float = 0.1

var rng : RandomNumberGenerator
const DOUBLE_VOL_DB = 10.0


func _init():
	rng = RandomNumberGenerator.new()
	rng.randomize()


func get_random_clip_index():
	return rng.randi_range(0, clips.size())


func get_random_clip() -> AudioStream:
	clips.shuffle()
	return get_clip()


func get_clip(i = 0) -> AudioStream:
	i = clamp(i, 0, clips.size()-1)
	return clips[i]


func get_next_track_index(ref :int) -> int:
	ref += 1
	if ref >= clips.size():
		ref = 0
	return ref


func get_previous_track_index(ref :int) -> int:
	ref -= 1
	if ref < 0:
		ref = clips.size()-1
	return ref


func get_pitch():
	return rng.randf_range(pitchMultiplier - pitchRandomness, pitchMultiplier + pitchRandomness)


func get_volume_multiplier():
	return volumeMultiplier


func get_volume_db():
	return linear_to_db(get_volume_multiplier())
