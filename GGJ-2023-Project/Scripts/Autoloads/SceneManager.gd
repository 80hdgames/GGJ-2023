extends CanvasLayer

enum {
	FREE,
	LOADING
}

var _state: int = 0
var _load_timer: float = 0
var _target_scene_path: String

var _fader

const EMPTY_STRING = ""
const FADE_OUT_DURATION = 0.5
const FADE_OUT_PREFAB = preload("res://Scenes/Prefabs/UI/FadeOut.tscn")


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 128
	#pause_mode = Node.PAUSE_MODE_PROCESS
	_fader = FADE_OUT_PREFAB.instantiate()
	#_fader.pause_mode = Node.PAUSE_MODE_PROCESS
	add_child(_fader)
	_fader.pause()


func is_loading() -> bool:
	return _state == LOADING


func go_to(path: String):
	if path == _target_scene_path:
		return
	#ParticleManager.set_active(false)
	
	assert(ResourceLoader.exists(path))
	_target_scene_path = path
	_load_timer = 0
	_state = LOADING
	_fader.resume()
	# warning-ignore:return_value_discarded
#	if get_tree().change_scene(path) != OK:
#		push_error("Failed to open scene at %s" % path)


func _swap_scene():
	if get_tree().change_scene_to_file(_target_scene_path) != OK:
		push_error("Failed to open scene at %s" % _target_scene_path)
	_state = FREE
	_fader.pause()
	_target_scene_path = EMPTY_STRING


func _physics_process(delta: float):
	match _state:
		FREE:
			return
		LOADING:
			if _load_timer >= FADE_OUT_DURATION:
				_swap_scene()
			_load_timer += delta
