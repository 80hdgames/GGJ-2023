class_name VeggieSpawner extends Node3D

const SoundType = SfxManager.SoundType

var spawnedVeggie

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func spawn_veggie(veggie):
	var v = veggie.instantiate()
	v.spawner = self
	add_child(v)
	v.global_transform.origin = global_transform.origin
	spawnedVeggie = v
	_bounce_veggie(v)

func has_veggie():
	return spawnedVeggie != null

func collected(pickup):
	spawnedVeggie = null
	get_parent().on_picked_collected(pickup)


func _bounce_veggie(v :Node3D):
	var startPos = v.position
	SfxManager.enqueue3d(SoundType.DirtScuffle, v.global_position)
	v.scale = Vector3.ONE * 1.25
	v.position = startPos-Vector3.UP*2
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(v, "scale", Vector3.ONE, 1)
	tween.tween_property(v, "position", startPos, 1)
	tween.play()
