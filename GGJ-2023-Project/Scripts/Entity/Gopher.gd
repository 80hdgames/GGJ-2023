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

var _stateTimer = DURATION 
@onready var avatar = $Gopher
@onready var dirtMound :Node3D = $DirtMound
@onready var gopherTunneling :GPUParticles3D = $GopherMounds
@onready var tunnelingAudio :AudioStreamPlayer3D = $TunnelingAudio


func _ready():
	_update_wander_direction()


func _physics_process(delta):
	_stateTimer -= delta
	var input_dir = Vector2.ZERO
	match _state:
		WANDER:
			# TODO: steer towards nearest veggie?
			input_dir = Vector2(_wanderDir.x, _wanderDir.z)
			if _stateTimer <= 0:
				_swap_state(PEEK)
		PEEK:
			if _stateTimer <= 0:
				_swap_state(WANDER)
				
	var direction :Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
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
	dirtMound.visible = _state == PEEK
	_stateTimer = DURATION + randf()
	match _state:
		PEEK:
			tunnelingAudio.stop()
			emit_signal("surface")
			avatar.play_one_shot("Peek")
		WANDER:
			tunnelingAudio.play()
			_update_wander_direction()
