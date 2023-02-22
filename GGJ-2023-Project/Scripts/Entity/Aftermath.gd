class_name Aftermath extends Node3D

@onready var cam = $Camera3D

const SoundType = SfxManager.SoundType
const PLACES = Constants.PLAYER_START_POSITIONS


func begin():
	cam.current = true
	SfxManager.enqueue2d(SoundType.PigSqueal)
	position_winners(PlayerManager.winners)


func move_to_place(p: Node3D, i: int):
	if i < PLACES.size():
		p.global_position = global_position + PLACES[wrapi(i, 0, PLACES.size())]


func position_winners(winners: Array[Node3D]):
	var i = 0
	for winner in winners:
		winner.jump() # jump for joy
		
		var cam_dir = get_viewport().get_camera_3d().global_position - winner.global_position
		var lookin = winner.global_transform.looking_at(global_transform.origin + cam_dir, Vector3.UP)
		var desired_rotation = lookin.basis.get_euler()
		winner.rotation.y = desired_rotation.y
		
		move_to_place(winner, i)
		i += 1
