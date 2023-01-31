extends Area3D

const PLAYER_NODE_GROUP = Constants.PLAYER_NODE_GROUP


func _ready():
	body_entered.connect(_on_body_entered)
	
	
func _on_body_entered(body):
	if body.is_in_group(PLAYER_NODE_GROUP):
		_collect()
		
		
func _collect():
	queue_free()
