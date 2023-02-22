class_name VeggieSpawner
extends Node3D

signal veggie_spawned(pos)

const SoundType = SfxManager.SoundType
const GROW_SOUND_DELAY = 0.5

var _spawned_veggie: Pickup


func _ready():
	pass


func _process(_delta):
	pass


func spawn_veggie(veggie) -> Node3D:
	var v = veggie.instantiate() as Pickup
	v.set_spawner(self)
	add_child(v)
	v.global_transform.origin = global_transform.origin
	_spawned_veggie = v
	_bounce_veggie(v)
	return v


func has_veggie() -> bool:
	return _spawned_veggie != null


func collected(pickup):
	_spawned_veggie = null
	get_parent().on_picked_collected(pickup)


func _play_grow_sound(v):
	SfxManager.enqueue3d(SoundType.Grow, v.global_position)


func _bounce_veggie(v: Node3D):
	var start_pos = v.position
	v.scale = Vector3.ONE * 1.25
	v.position = start_pos - Vector3.UP * 2
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(v, "scale", Vector3.ONE, 1)
	tween.tween_property(v, "position", start_pos, 1)
	tween.tween_callback(_play_grow_sound.bind(v)).set_delay(GROW_SOUND_DELAY)
	#tween.tween_callback(emit_spawn_signal.bind(v)).set_delay(GROW_SOUND_DELAY)
	#tween.finished.connect(emit_spawned_signal.bind(v))
	tween.play()


func emit_spawn_signal(v: Node3D):
	if not is_instance_valid(v):
		return
	emit_signal("veggie_spawned", v.global_position)
