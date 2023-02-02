extends Camera3D

const PLAYER_NODE_GROUP = Constants.PLAYER_NODE_GROUP
const CAM_SPEED = 2.0
const CAM_ZOOM_SPEED = 10.0
const CAM_ZOOM_MAX = 20.0
const EXTENTS = 5.0

var _players :Array = []
var _maxSqrDistance :float = 0.0
@onready var _smoothedFovAdjust :float = fov
@onready var _defaultFov :float = fov


func _ready():
	call_deferred("_acquire_targets")


func _acquire_targets():
	_players = get_tree().get_nodes_in_group(PLAYER_NODE_GROUP)


func _physics_process(_delta):
	_maxSqrDistance = 0.0
	if _players.is_empty():
		return
		
	var averagePos :Vector3 = Vector3.ZERO
	for p in _players:
		_maxSqrDistance = max(_maxSqrDistance, abs(global_transform.origin.x - p.global_transform.origin.x))
		averagePos += p.global_transform.origin
	averagePos /= _players.size()
	
#	look_at(averagePos)
	global_position.x = lerp(global_position.x, averagePos.x, CAM_SPEED * _delta)
#	global_position.x = clamp(global_position.x, -EXTENTS, EXTENTS)
	_smoothedFovAdjust = move_toward(fov, _defaultFov + clamp(_maxSqrDistance, 0.0, CAM_ZOOM_MAX), CAM_ZOOM_SPEED * _delta)
	fov = _smoothedFovAdjust
