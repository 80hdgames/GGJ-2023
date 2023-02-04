extends CharacterBody3D

enum {
	WANDER,
	PEEK
}

const SoundType = SfxManager.SoundType
const SPEED :float = 4.0
const DURATION :float = 3.0

signal surface

var _state :int = PEEK
var _wanderDir :Vector3
var _veggieNodes :Array = []

var _stateTimer = DURATION 
@onready var avatar = $Gopher
@onready var dirtMound :Node3D = $DirtMound
@onready var gopherTunneling :GPUParticles3D = $GopherMounds
@onready var tunnelingAudio :AudioStreamPlayer3D = $TunnelingAudio


func _ready():
	_update_wander_direction()


func _physics_process(delta):
	_stateTimer -= delta
	match _state:
		WANDER:
			# TODO: steer towards nearest veggie?
			if not _veggieNodes.is_empty():
				var veggieDir :Vector3 = _veggieNodes[0].global_position - global_position
				_wanderDir += veggieDir * delta
				_wanderDir = _wanderDir.normalized()
			if _stateTimer <= 0:
				_swap_state(PEEK)
		PEEK:
			_wanderDir = Vector3.ZERO
			if _stateTimer <= 0:
				_swap_state(WANDER)
				
	#var direction :Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var direction = _wanderDir
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func _update_wander_direction():
	_wanderDir = Vector3(randf_range(-1.0, 1.0), 0, randf_range(-1.0, 1.0))
	_wanderDir = _wanderDir.normalized()


func _swap_state(_next :int):
	SfxManager.enqueue3d(SoundType.DirtScuffle, global_position)
	_state = _next
	gopherTunneling.emitting = _state == WANDER
	_stateTimer = DURATION + randf()
	match _state:
		PEEK:
			dirtMound.scale = Vector3.ONE
			dirtMound.show()
			tunnelingAudio.stop()
			emit_signal("surface")
			avatar.play_one_shot("Peek")
		WANDER:
			_update_veggie_nodes()
			_tween_away_mound()
			tunnelingAudio.play()
			_update_wander_direction()


func _tween_away_mound():
	var tween = create_tween()
	tween.tween_property(dirtMound, "scale", Vector3.ONE*0.01, 0.15)
	tween.play()


func _update_veggie_nodes():
	_veggieNodes = get_tree().get_nodes_in_group("Veggie")
	for v in _veggieNodes:
		var node = (v as Node)
		if not node.is_connected("tree_exiting", _cleanup_veggie_ref.bind(v)):
			node.tree_exiting.connect(_cleanup_veggie_ref.bind(node))
	_veggieNodes.shuffle()


func _cleanup_veggie_ref(v :Node):
	v.tree_exiting.disconnect(_cleanup_veggie_ref)
	_veggieNodes.erase(v)
