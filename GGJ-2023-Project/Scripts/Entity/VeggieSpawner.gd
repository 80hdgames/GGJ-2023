class_name VeggieSpawner extends Node3D

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

func has_veggie():
	return spawnedVeggie != null

func collected(pickup):
	spawnedVeggie = null
	get_parent().on_picked_collected(pickup)
