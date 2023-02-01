extends Camera3D

const PLAYER_NODE_GROUP = Constants.PLAYER_NODE_GROUP
const CAM_SPEED = 2.0
const EXTENTS = 5.0

var _players :Array = []


func _ready():
	call_deferred("_acquire_targets")


func _acquire_targets():
	_players = get_tree().get_nodes_in_group(PLAYER_NODE_GROUP)


func _physics_process(_delta):
	if _players.is_empty():
		return
		
	var averagePos :Vector3 = Vector3.ZERO
	for p in _players:
		averagePos += p.global_transform.origin
	averagePos /= _players.size()
	
#	look_at(averagePos)
	global_position.x = lerp(global_position.x, averagePos.x, CAM_SPEED * _delta)
#	global_position.x = clamp(global_position.x, -EXTENTS, EXTENTS)
