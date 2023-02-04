class_name Aftermath extends Node3D

@onready var cam = $Camera3D

const SoundType = SfxManager.SoundType
const PLACES = Constants.PLAYER_START_POSITIONS


func begin():
	cam.current = true
	SfxManager.enqueue2d(SoundType.PigSqueal)
	position_winners(PlayerManager.winners)


func move_to_place(p :Node3D, i :int):
	if i < PLACES.size():
		p.global_position = global_position + (Vector3.RIGHT*5) + PLACES[wrapi(i, 0, PLACES.size())]


func position_winners(winners :Array[Node3D]):
	var i = 0
	for winner in winners:
		winner._jump() # jump for joy
		
		var camDir = get_viewport().get_camera_3d().global_position - winner.global_position
		var lookin = winner.global_transform.looking_at(global_transform.origin + camDir, Vector3.UP)
		var desiredRotation = lookin.basis.get_euler()
		winner.rotation.y = desiredRotation.y
		
		move_to_place(winner, i)
		i += 1
