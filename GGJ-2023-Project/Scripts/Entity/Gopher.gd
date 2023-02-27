extends CharacterBody3D

enum {
	WANDER,
	PEEK
}

const SoundType = SfxManager.SoundType
const SPEED: float = 4.0
const DURATION: float = 3.0

signal surface

var _state: int = PEEK
var _wander_dir: Vector3
var _veggie_positions: Array[Vector3] = []

var _state_timer = DURATION 
@onready var _avatar = $Gopher
@onready var _dirt_mound: Node3D = $DirtMound
@onready var _gopher_tunneling: GPUParticles3D = $GopherMounds
@onready var _tunneling_audio: AudioStreamPlayer3D = $TunnelingAudio


func _ready():
	_update_wander_direction()


func _physics_process(delta):
	_state_timer -= delta
	match _state:
		WANDER:
			# TODO: steer towards nearest veggie?
			if not _veggie_positions.is_empty():
				var veggieDir: Vector3 = _veggie_positions[0] - global_position
				_wander_dir += veggieDir * delta
				_wander_dir = _wander_dir.normalized()
			if _state_timer <= 0:
				_swap_state(PEEK)
		PEEK:
			_wander_dir = Vector3.ZERO
			if _state_timer <= 0:
				_swap_state(WANDER)
				
	#var direction :Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var direction = _wander_dir
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func _update_wander_direction():
	_wander_dir = Vector3(randf_range(-1.0, 1.0), 0, randf_range(-1.0, 1.0))
	_wander_dir = _wander_dir.normalized()


func _swap_state(_next: int):
	SfxManager.enqueue3d(SoundType.DirtScuffle, global_position)
	_state = _next
	_gopher_tunneling.emitting = _state == WANDER
	_state_timer = DURATION + randf()
	match _state:
		PEEK:
			_dirt_mound.scale = Vector3.ONE
			_dirt_mound.show()
			_tunneling_audio.stop()
			emit_signal("surface")
			_avatar.play_one_shot("Peek")
		WANDER:
			_update_veggie_nodes()
			_tween_away_mound()
			_tunneling_audio.play()
			_update_wander_direction()


func _tween_away_mound():
	var tween = create_tween()
	tween.tween_property(_dirt_mound, "scale", Vector3.ONE*0.01, 0.15)
	tween.play()


func _update_veggie_nodes():
	_veggie_positions.clear()
	var veggie_nodes = get_tree().get_nodes_in_group("Veggie")
	for v in veggie_nodes:
		var node = (v as Node3D)
		_veggie_positions.append(v.global_position)
