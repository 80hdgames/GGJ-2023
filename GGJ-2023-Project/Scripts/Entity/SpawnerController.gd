extends Node3D

const SPAWNER_GROUP = "VeggieSpawners"
const SPAWN_ATTEMPTS = 12
const SPAWN_DELAY_START = 4.0
const SPAWN_DELAY_END = 0.5

const POTATO_PREFAB = preload("res://Scenes/Prefabs/Pickups/Potato.tscn")
const CARROT_PREFAB = preload("res://Scenes/Prefabs/Pickups/Carrot.tscn")
const ONION_PREFAB = preload("res://Scenes/Prefabs/Pickups/Onion.tscn")
const TURNIP_PREFAB = preload("res://Scenes/Prefabs/Pickups/Turnip.tscn")

const VEGGIE_PREFABS :Array = [
	POTATO_PREFAB,
	CARROT_PREFAB,
	ONION_PREFAB,
	TURNIP_PREFAB
]

var spawners :Array = []
var rng = RandomNumberGenerator.new()
#var veggie_prefabs :Array = []

var hud_node
var roundLength = 0
var lastSpawnTime = 0

@onready var smokePuff :GPUParticles3D = $SmokePuff
@onready var dirtClods :GPUParticles3D = $DirtClods
@onready var sparkles :GPUParticles3D = $Sparkles

# Called when the node enters the scene tree for the first time.
func _ready():
	spawners = get_tree().get_nodes_in_group(SPAWNER_GROUP)
	assert(len(spawners) > 0, "No veggie spawnpoints found")
	for s in spawners:
		s.veggie_spawned.connect(_emit_poof)
	
#	setup_veggies_list()
	
	var huds :Array = get_tree().get_nodes_in_group(Constants.HUD_NODE_GROUP)
	assert(len(huds) > 0, "Failed to find HUD timer")
	hud_node = huds[0]
	roundLength = hud_node.get_time_left()
	
	rng.randomize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if (should_spawn()):
		spawn_random_veggie()

func should_spawn():
	var roundProgress = clamp(time_elapsed() / roundLength, 0, 1)
	var spawnDelay = lerp(SPAWN_DELAY_START, SPAWN_DELAY_END, roundProgress)
	
	return time_elapsed() >= lastSpawnTime + spawnDelay

#func setup_veggies_list():
#	veggie_prefabs.append(POTATO_PREFAB)
#	veggie_prefabs.append(CARROT_PREFAB)
#	assert(len(veggie_prefabs) > 0, "No veggies configured for spawning")

func get_random_veggie():
#	var veggie_index = rng.randi_range(0, len(veggie_prefabs) - 1)
#	return veggie_prefabs[veggie_index]
	var veggie_index = rng.randi_range(0, len(VEGGIE_PREFABS) - 1)
	return VEGGIE_PREFABS[veggie_index]

func spawn_random_veggie():
	var veggie_prefab = get_random_veggie()
	
	for n in SPAWN_ATTEMPTS: # Make several attempts to find a clear spawn
		var spawner_index = rng.randi_range(0, len(spawners) - 1)
		var spawner = spawners[spawner_index]
		if !spawner.has_veggie():
			var _v :Node3D = spawner.spawn_veggie(veggie_prefab)
			_emit_poof(_v.global_position + Vector3.UP)
			break # Spawn succeeded, don't make any more attempts!
	
	lastSpawnTime = time_elapsed()

func time_elapsed():
	return roundLength - hud_node.get_time_left()

func on_picked_collected(pickup):
	lastSpawnTime -= pickup.timeBonus
	sparkles.global_position = pickup.global_position + Vector3.UP
	sparkles.emit()


func _emit_poof(pos :Vector3):
	smokePuff.global_position = pos
	dirtClods.global_position = pos
	smokePuff.emit()
	dirtClods.emit()
	
