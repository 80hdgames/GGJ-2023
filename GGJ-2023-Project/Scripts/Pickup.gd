extends Area3D

@export var pointValue :int = 1

const PLAYER_NODE_GROUP = Constants.PLAYER_NODE_GROUP
const HUD_NODE_GROUP = Constants.HUD_NODE_GROUP
const SoundType = SfxManager.SoundType


func _ready():
	body_entered.connect(_on_body_entered)
	
	
func _on_body_entered(body):
	if body.is_in_group(PLAYER_NODE_GROUP):
		_collect(body)
		
		
func _collect(body):
	get_tree().call_group(HUD_NODE_GROUP, "add_points", body, pointValue)
	queue_free()
