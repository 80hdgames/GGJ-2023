extends Node3D

const SPAWNER_GROUP = "VeggieSpawners"
const SPAWN_ATTEMPTS = 12
const SPAWN_DELAY_START = 4.0
const SPAWN_DELAY_END = 0.5

const POTATO_PREFAB = preload("res://Scenes/Prefabs/Pickups/Potato.tscn")
const CARROT_PREFAB = preload("res://Scenes/Prefabs/Pickups/Carrot.tscn")
const ONION_PREFAB = preload("res://Scenes/Prefabs/Pickups/Onion.tscn")
const TURNIP_PREFAB = preload("res://Scenes/Prefabs/Pickups/Turnip.tscn")

const VEGGIE_PREFABS: Array = [
	POTATO_PREFAB,
	CARROT_PREFAB,
	ONION_PREFAB,
	TURNIP_PREFAB
]

var spawners: Array = []
var rng = RandomNumberGenerator.new()

var _hud_node
var _round_length = 0
var _last_spawn_time = 0

@onready var smokePuff: GPUParticles3D = $SmokePuff
@onready var dirtClods: GPUParticles3D = $DirtClods
@onready var sparkles: GPUParticles3D = $Sparkles


func _ready():
	spawners = get_tree().get_nodes_in_group(SPAWNER_GROUP)
	assert(len(spawners) > 0, "No veggie spawnpoints found")
	for s in spawners:
		s.veggie_spawned.connect(_emit_poof)
	
	var huds: Array = get_tree().get_nodes_in_group(Constants.HUD_NODE_GROUP)
	assert(len(huds) > 0, "Failed to find HUD timer")
	_hud_node = huds[0]
	_round_length = _hud_node.get_time_left()
	
	rng.randomize()


func _process(_delta):
	if (_should_spawn()):
		_spawn_random_veggie()


func on_picked_collected(pickup):
	_last_spawn_time -= pickup.time_bonus
	sparkles.global_position = pickup.global_position + Vector3.UP
	sparkles.emit()


func _should_spawn():
	var roundProgress = clamp(_time_elapsed() / _round_length, 0, 1)
	var spawnDelay = lerp(SPAWN_DELAY_START, SPAWN_DELAY_END, roundProgress)
	
	return _time_elapsed() >= _last_spawn_time + spawnDelay


func _get_random_veggie():
#	var veggie_index = rng.randi_range(0, len(veggie_prefabs) - 1)
#	return veggie_prefabs[veggie_index]
	var veggie_index = rng.randi_range(0, len(VEGGIE_PREFABS) - 1)
	return VEGGIE_PREFABS[veggie_index]


func _spawn_random_veggie():
	var veggie_prefab = _get_random_veggie()
	
	for n in SPAWN_ATTEMPTS: # Make several attempts to find a clear spawn
		var spawner_index = rng.randi_range(0, len(spawners) - 1)
		var spawner = spawners[spawner_index]
		if spawner.can_spawn_veggie():
			var _v :Node3D = spawner.spawn_veggie(veggie_prefab)
			_emit_poof(_v.global_position + Vector3.UP)
			break # Spawn succeeded, don't make any more attempts!
	
	_last_spawn_time = _time_elapsed()


func _time_elapsed():
	return _round_length - _hud_node.get_time_left()
	

func _emit_poof(pos :Vector3):
	smokePuff.global_position = pos
	dirtClods.global_position = pos
	smokePuff.emit()
	dirtClods.emit()
	
