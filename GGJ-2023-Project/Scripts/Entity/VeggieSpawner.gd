class_name VeggieSpawner extends Node3D

const SoundType = SfxManager.SoundType
const GROW_SOUND_DELAY = 0.5

signal veggie_spawned(pos)
var spawnedVeggie

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func spawn_veggie(veggie) -> Node3D:
	var v = veggie.instantiate()
	v.spawner = self
	add_child(v)
	v.global_transform.origin = global_transform.origin
	spawnedVeggie = v
	_bounce_veggie(v)
	return v

func has_veggie():
	return spawnedVeggie != null

func collected(pickup):
	spawnedVeggie = null
	get_parent().on_picked_collected(pickup)

func play_grow_sound(v):
	SfxManager.enqueue3d(SoundType.Grow, v.global_position)

func _bounce_veggie(v :Node3D):
	var startPos = v.position
	#SfxManager.enqueue3d(SoundType.Grow, v.global_position)
	v.scale = Vector3.ONE * 1.25
	v.position = startPos-Vector3.UP*2
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(v, "scale", Vector3.ONE, 1)
	tween.tween_property(v, "position", startPos, 1)
	tween.tween_callback(play_grow_sound.bind(v)).set_delay(GROW_SOUND_DELAY)
	#tween.tween_callback(emit_spawn_signal.bind(v)).set_delay(GROW_SOUND_DELAY)
	#tween.finished.connect(emit_spawned_signal.bind(v))
	tween.play()


func emit_spawn_signal(v :Node3D):
	if not is_instance_valid(v):
		return
	emit_signal("veggie_spawned", v.global_position)
