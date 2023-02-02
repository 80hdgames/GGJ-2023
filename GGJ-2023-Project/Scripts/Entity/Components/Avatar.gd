class_name Avatar extends Node3D

@export_node_path("MeshInstance3D") var tintNodePath :NodePath
@onready var animPlayer :AnimationPlayer = $AnimationPlayer
@onready var meshInstance :MeshInstance3D = get_node(tintNodePath)

const ONE_SHOT_ANIMATIONS :Array[String] = [
	"Land",
	"Jump",
	"Dig"
]


func play(animName :String, blend :float = 0.3):
	if _is_playing_one_shot_anim():
		return
	animPlayer.play(animName, blend)


func play_one_shot(animName :String, blend :float = 0.3):
	animPlayer.stop(true)
	play(animName, blend)


func _is_playing_one_shot_anim():
	return ONE_SHOT_ANIMATIONS.has(animPlayer.current_animation)


func set_color(_c :Color):
	assert(meshInstance)
	if meshInstance:
		meshInstance.set_instance_shader_parameter("tint", _c)
