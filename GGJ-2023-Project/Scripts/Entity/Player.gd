extends CharacterBody3D

signal scuff_ground
signal fart

enum AnimType {
	Idle,
	Run,
	Dash,
	Jump,
	InAir,
	Land,
	Dig,
}

const ANIM_LOOKUP: Dictionary = {
	AnimType.Idle: "Idle",
	AnimType.Run: "Run",
	AnimType.Dash: "Dash",
	AnimType.Jump: "Jump",
	AnimType.InAir: "In_Air",
	AnimType.Land: "Land",
	AnimType.Dig: "Dig",
}

const SoundType = SfxManager.SoundType
const SPEED = 5.0
const GRIP = 0.25
const TURN_SPEED = 0.2
const JUMP_VELOCITY = 4.5
const TITLE_SCREEN_SCENE = Constants.TITLE_SCREEN_SCENE
const MAX_BOOST = 1
const BOOST_SPEED = 4
const BOOST_RECHARGE_RATE = 0.5
const BOOST_BURN_RATE = 0.8
const BOOST_MIDAIR_VELOCITY = 20
const ROTATION_MULTIPLIER = 10.0
const IN_AIR_THRESHOLD = 0.3
const GAMEPAD_DEVICE_ID_ADD = Constants.GAMEPAD_DEVICE_ID_ADD
const PLAYER_COLORS = Constants.PLAYER_COLORS

var _player_id: int = -1
var _device_id: int = -10

# Get the _gravity from the project settings to be synced with RigidBody nodes.
var _gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var _boost_charge = MAX_BOOST
var _is_boosting: bool = false
var _hang_time: float = 0.0
var _input_dir: Vector2 = Vector2.ZERO
var _move_impulse: Vector3 = Vector3.FORWARD
@onready var _avatar: Avatar = $Piggy_Avatar
#@onready var _collision_shape :CollisionShape3D = $CollisionShape3D


func _ready():
	PlayerManager.register_player_instance(self)
	rotation.y = randf_range(-180, 180)


func _physics_process(delta):
	var is_airborne: bool = false
	# Add the _gravity.
	if not is_on_floor():
		is_airborne = true
		_hang_time += delta
		velocity.y -= _gravity * delta

	if _is_boosting:
		_boost_charge = max(0, _boost_charge - BOOST_BURN_RATE * delta)
		if _boost_charge <= 0:
			_is_boosting = false
	else:
		_boost_charge = min(_boost_charge + BOOST_RECHARGE_RATE * delta, MAX_BOOST)
		if can_boost():
			_avatar.set_emission(Color.BLACK)

	var boost = BOOST_SPEED if _is_boosting else 0

	# Get the input direction and handle the movement/deceleration.
	_process_move_input()
	#_move_impulse = (transform.basis * Vector3(_input_dir.x, 0, _input_dir.y)).normalized()
	_move_impulse = Vector3(_input_dir.x, 0, _input_dir.y).normalized()
	if _move_impulse:
		velocity.x = move_toward(velocity.x, _move_impulse.x * (SPEED + boost), GRIP)
		velocity.z = move_toward(velocity.z, _move_impulse.z * (SPEED + boost), GRIP)
	else:
		velocity.x = move_toward(velocity.x, 0, GRIP)
		velocity.z = move_toward(velocity.z, 0, GRIP)

	move_and_slide()
	
	# update rotation, using radians
	_update_desired_rotation(delta)
	
	if is_on_floor():
		if is_airborne:
			if _hang_time >= IN_AIR_THRESHOLD:
				_avatar.play_one_shot(ANIM_LOOKUP.get(AnimType.Land))
			_hang_time = 0.0
		
	_update_animation(_move_impulse)


func _unhandled_input(_event: InputEvent):
	if get_tree().paused or not _event.is_pressed():
		return
		
		
	if _device_id >= 0:
		if _event.is_action_pressed("%s_jump" % _get_input_action_prefix()) and is_on_floor():
			jump()

		if _event.is_action_pressed("%s_boost" % _get_input_action_prefix()) and can_boost():
			_activate_boost()
			
	else: # less than zero is no assigned device
		if _event is InputEventJoypadButton:
			if InputManager.register_device(_event.device + GAMEPAD_DEVICE_ID_ADD, self):
				_assign_device_id(_event.device + GAMEPAD_DEVICE_ID_ADD)
			else:
				return
		elif (_event is InputEventMouseButton) or (_event is InputEventKey):
			# 2 desktop players check
			if _event.is_action_pressed("desktop1_down") or _event.is_action_pressed("desktop1_up") or \
			_event.is_action_pressed("desktop1_left") or _event.is_action_pressed("desktop1_right"):
				if InputManager.register_device(_event.device, self):
					_assign_device_id(_event.device)
				else:
					return
			elif _event.is_action_pressed("desktop2_down") or _event.is_action_pressed("desktop2_up") or \
			_event.is_action_pressed("desktop2_left") or _event.is_action_pressed("desktop2_right"):
				if InputManager.register_device(_event.device + 1, self):
					_assign_device_id(_event.device + 1)


func get_my_color(i: int):
	return PLAYER_COLORS[wrapi(i, 0, PLAYER_COLORS.size())]


func set_player_id(i: int):
	_player_id = i
	_avatar.set_color(get_my_color(i))


func can_boost():
	return _boost_charge >= 1 and not _is_boosting


func _activate_boost():
	_is_boosting = true
	_avatar.set_emission(Color.WHITE)
	SfxManager.enqueue3d(SoundType.PigSqueal, global_transform.origin)
	if not is_on_floor():
		SfxManager.enqueue3d(SoundType.Fart, global_transform.origin)
		emit_signal("fart")
		
		# give the piggy a little boost in the direction they're facing
		var facing = -get_global_transform().basis.z.normalized()
		var flat_vel = velocity
		flat_vel.y = 0
		# scale air boost down based on how fast the pig is moving
		var factor = flat_vel.length() / SPEED
		velocity += facing * (1 - factor) * BOOST_MIDAIR_VELOCITY

func _update_animation(direction: Vector3):
	# old rotation, just rotates _avatar
	if direction != Vector3.ZERO:
#		var smoothedDirection = _avatar.global_transform.basis.z.slerp(direction, TURN_SPEED)
#		_avatar.look_at(global_transform.origin - smoothedDirection)
#		var facingDiff = _avatar.global_transform.basis.z.dot(direction)
#		var skidStrength = 1 - ((facingDiff + 1) / 2)
		
		# TODO: dirt/dust particles when piggies are skidding
		# skidStrength is 0 when piggies are facing the direction they're moving,
		# and 1 when piggies are facing opposite to their movement.
		# We can scale effect strength based on this value!
		pass

	if is_on_floor():
		if not _is_boosting:
			_avatar.play(ANIM_LOOKUP.get(AnimType.Run) if direction != Vector3.ZERO else ANIM_LOOKUP.get(AnimType.Idle))
		else:
			_avatar.play(ANIM_LOOKUP.get(AnimType.Dash) if direction != Vector3.ZERO else ANIM_LOOKUP.get(AnimType.Idle))
	else:
		if _hang_time >= IN_AIR_THRESHOLD:
			_avatar.play(ANIM_LOOKUP.get(AnimType.InAir))


func jump():
	_avatar.play_one_shot(ANIM_LOOKUP.get(AnimType.Jump))
	# TODO: poof vfx
	velocity.y = JUMP_VELOCITY
	SfxManager.enqueue3d(SoundType.PigGrunt, global_transform.origin)


func _scuff_ground():
	emit_signal("scuff_ground")


func _process_move_input():
	if _device_id < 0:
		return
		
	_input_dir = Input.get_vector("%s_left" % _get_input_action_prefix(), \
	"%s_right" % _get_input_action_prefix(), \
	"%s_up" % _get_input_action_prefix(), \
	"%s_down" % _get_input_action_prefix())


func _update_desired_rotation(delta):
	var test: Vector3 = _move_impulse
	test.y = 0
	if test.is_equal_approx(Vector3.ZERO):
		return
	
	var lookin = global_transform.looking_at(global_transform.origin + test, Vector3.UP)
	var desired_rotation = lookin.basis.get_euler()
	rotation.y = lerp_angle(rotation.y, desired_rotation.y, delta * ROTATION_MULTIPLIER)


func _assign_device_id(id: int):
	_device_id = id
	if _device_id > 0:
		InputManager.rumble(-GAMEPAD_DEVICE_ID_ADD, 0.25)

#	decal.visible = true
	
	_avatar.scale = Vector3(2, 1, 2)
		
	bounce(2)
	# warning-ignore:return_value_discarded
#	tween.interpolate_property(decal, "modulate", Color(2,2,2,1), PLAYER_COLORS[_device_id % PLAYER_COLORS.size()], 1.0, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
#	_bounce()
	print("%s device now %s" % [self, _device_id])
	SfxManager.enqueue3d(SoundType.PigGrunt, global_transform.origin)


func _on_assign_device_complete():
	if _device_id > 0:
		InputManager.stop_rumble(_device_id - GAMEPAD_DEVICE_ID_ADD)


func bounce(_magnitude: float = 1.25):
	_avatar.scale = Vector3(_magnitude, 1, _magnitude)
		
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(_avatar, "scale", Vector3.ONE, 0.5)
	tween.finished.connect(_on_assign_device_complete)


func reset_device():
	_device_id = -10
#	decal.visible = false


func game_over():
#	set_physics_process(false)
	set_process_unhandled_input(false)
	set_process_input(false)
	reset_device()
	
	_input_dir = Vector2.ZERO
	_move_impulse = Vector3.ZERO
	
	# look at camera
#	var targetPos = get_viewport().get_camera_3d().global_position - global_position
#	targetPos.y = global_position.y
#	look_at(targetPos)


func _get_input_action_prefix() -> String:
	if _device_id < 0:
		return ""
	elif _device_id < GAMEPAD_DEVICE_ID_ADD:
		return "desktop%s" % (_device_id + 1)
	else:
		return "joy%s" % (_device_id - GAMEPAD_DEVICE_ID_ADD + 1)


func _on_avatar_footstep():
	SfxManager.enqueue3d(SoundType.Footstep, global_position)
	_scuff_ground()


func _on_piggy_avatar_scuff():
	if _hang_time < IN_AIR_THRESHOLD:
		_scuff_ground()
