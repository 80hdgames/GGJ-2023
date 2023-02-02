class_name Avatar extends Node3D

@export_node_path("MeshInstance3D") var tintNodePath :NodePath
@onready var animPlayer :AnimationPlayer = $AnimationPlayer
@onready var meshInstance :MeshInstance3D = get_node_or_null(tintNodePath)

signal footstep

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
	_footstep()
	animPlayer.stop(true)
	play(animName, blend)


func _is_playing_one_shot_anim():
	return ONE_SHOT_ANIMATIONS.has(animPlayer.current_animation)


func set_color(_c :Color):
	assert(meshInstance)
	if meshInstance:
		meshInstance.set_instance_shader_parameter("tint", _c)


func _process(_delta):
	if animPlayer.current_animation == "Dash":
		_footstep()


func _footstep():
	emit_signal("footstep")
