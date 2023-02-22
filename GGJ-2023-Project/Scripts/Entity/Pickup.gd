class_name Pickup
extends Area3D

const PLAYER_NODE_GROUP = Constants.PLAYER_NODE_GROUP
const HUD_NODE_GROUP = Constants.HUD_NODE_GROUP
const SoundType = SfxManager.SoundType

@export var point_value: int = 1
@export var time_bonus: float = 0.0

var _spawner: VeggieSpawner


func _ready():
	body_entered.connect(_on_body_entered)
	
	
func _on_body_entered(body):
	if (body.is_in_group(PLAYER_NODE_GROUP)
			or body.is_in_group("Gopher")):
		_collect(body)


func set_spawner(spawner: VeggieSpawner):
	_spawner = spawner


func _collect(body):
	if _spawner:
		_spawner.collected(self)
	
	SfxManager.enqueue3d(SoundType.Collect, global_position)
	if body.is_in_group(PLAYER_NODE_GROUP):
		body.bounce()
		get_tree().call_group(HUD_NODE_GROUP, "add_points", body, point_value, time_bonus)
	queue_free()
