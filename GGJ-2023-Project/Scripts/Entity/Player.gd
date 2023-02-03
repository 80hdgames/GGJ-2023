extends CharacterBody3D

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
const IN_AIR_THRSHOLD = 0.3
const GAMEPAD_DEVICE_ID_ADD = Constants.GAMEPAD_DEVICE_ID_ADD
const PLAYER_COLORS = Constants.PLAYER_COLORS

signal scuff_ground
signal fart

var playerId :int = -1
var deviceId :int = -10

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var boostCharge = MAX_BOOST
var isBoosting :bool = false
var hangTime :float = 0.0
var inputDir :Vector2 = Vector2.ZERO
var moveImpulse :Vector3 = Vector3.FORWARD
@onready var avatar :Avatar = $Piggy_Avatar
@onready var collisionShape :CollisionShape3D = $CollisionShape3D

enum AnimType {
	Idle,
	Run,
	Dash,
	Jump,
	InAir,
	Land,
	Dig
}

const ANIM_LOOKUP :Dictionary = {
	AnimType.Idle: "Idle",
	AnimType.Run: "Run",
	AnimType.Dash: "Dash",
	AnimType.Jump: "Jump",
	AnimType.InAir: "In_Air",
	AnimType.Land: "Land",
	AnimType.Dig: "Dig",
}


func _ready():
	PlayerManager.register_player_instance(self)
	rotation.y = randf_range(-180, 180)


func set_player_id(i :int):
	playerId = i
	avatar.set_color(PLAYER_COLORS[wrapi(i, 0, PLAYER_COLORS.size())])


func can_boost():
	return boostCharge >= 1 and !isBoosting


func activate_boost():
	isBoosting = true
	SfxManager.enqueue3d(SoundType.PigSqueal, global_transform.origin)
	if not is_on_floor():
		SfxManager.enqueue3d(SoundType.Fart, global_transform.origin)
		emit_signal("fart")
		
		# give the piggy a little boost in the direction they're facing
		var facing = -get_global_transform().basis.z.normalized()
		var flatVel = velocity
		flatVel.y = 0
		# scale air boost down based on how fast the pig is moving
		var factor = flatVel.length() / SPEED
		velocity += facing * (1 - factor) * BOOST_MIDAIR_VELOCITY


func _unhandled_input(_event :InputEvent):
	if _event.is_action_pressed("menu"):
		SceneManager.go_to(TITLE_SCREEN_SCENE)
	
	if get_tree().paused or not _event.is_pressed():
		return
		
		
	if deviceId >= 0:
		if _event.is_action_pressed("%s_jump" % _get_input_action_prefix()) and is_on_floor():
			_jump()

		if _event.is_action_pressed("%s_boost" % _get_input_action_prefix()) and can_boost():
			activate_boost()
			
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
					
	


func _physics_process(delta):
	var isAirborne :bool = false
	# Add the gravity.
	if not is_on_floor():
		isAirborne = true
		hangTime += delta
		velocity.y -= gravity * delta

	if isBoosting:
		boostCharge = max(0, boostCharge - BOOST_BURN_RATE * delta)
		if boostCharge <= 0:
			isBoosting = false
	else:
		boostCharge = min(boostCharge + BOOST_RECHARGE_RATE * delta, MAX_BOOST)

	var boost = BOOST_SPEED if isBoosting else 0

	# Get the input direction and handle the movement/deceleration.
	_process_move_input()
	#moveImpulse = (transform.basis * Vector3(inputDir.x, 0, inputDir.y)).normalized()
	moveImpulse = Vector3(inputDir.x, 0, inputDir.y).normalized()
	if moveImpulse:
		velocity.x = move_toward(velocity.x, moveImpulse.x * (SPEED + boost), GRIP)
		velocity.z = move_toward(velocity.z, moveImpulse.z * (SPEED + boost), GRIP)
	else:
		velocity.x = move_toward(velocity.x, 0, GRIP)
		velocity.z = move_toward(velocity.z, 0, GRIP)

	move_and_slide()
	
	# update rotation, using radians
	_update_desired_rotation(delta)
	
	if is_on_floor():
		if isAirborne:
			if hangTime >= IN_AIR_THRSHOLD:
				avatar.play_one_shot(ANIM_LOOKUP.get(AnimType.Land))
			hangTime = 0.0
		
	_update_animation(moveImpulse)


func _update_animation(direction :Vector3):
	# old rotation, just rotates avatar
	if direction != Vector3.ZERO:
#		var smoothedDirection = avatar.global_transform.basis.z.slerp(direction, TURN_SPEED)
#		avatar.look_at(global_transform.origin - smoothedDirection)
#		var facingDiff = avatar.global_transform.basis.z.dot(direction)
#		var skidStrength = 1 - ((facingDiff + 1) / 2)
		
		# TODO: dirt/dust particles when piggies are skidding
		# skidStrength is 0 when piggies are facing the direction they're moving,
		# and 1 when piggies are facing opposite to their movement.
		# We can scale effect strength based on this value!
		pass

	if is_on_floor():
		if not isBoosting:
			avatar.play(ANIM_LOOKUP.get(AnimType.Run) if direction != Vector3.ZERO else ANIM_LOOKUP.get(AnimType.Idle))
		else:
			avatar.play(ANIM_LOOKUP.get(AnimType.Dash) if direction != Vector3.ZERO else ANIM_LOOKUP.get(AnimType.Idle))
	else:
		if hangTime >= IN_AIR_THRSHOLD:
			avatar.play(ANIM_LOOKUP.get(AnimType.InAir))


func _jump():
	avatar.play_one_shot(ANIM_LOOKUP.get(AnimType.Jump))
	# TODO: poof vfx
	velocity.y = JUMP_VELOCITY
	SfxManager.enqueue3d(SoundType.PigGrunt, global_transform.origin)


func _scuff_ground():
	emit_signal("scuff_ground")


func _process_move_input():
	if deviceId < 0:
		return
		
	inputDir = Input.get_vector("%s_left" % _get_input_action_prefix(), \
	"%s_right" % _get_input_action_prefix(), \
	"%s_up" % _get_input_action_prefix(), \
	"%s_down" % _get_input_action_prefix())


func _update_desired_rotation(delta):
	var test :Vector3 = moveImpulse
	test.y = 0
	if test.is_equal_approx(Vector3.ZERO):
		return
	var lookin = global_transform.looking_at(global_transform.origin + test, Vector3.UP)
	var desiredRotation = lookin.basis.get_euler()
	rotation.y = lerp_angle(rotation.y, desiredRotation.y, delta * ROTATION_MULTIPLIER)


func _assign_device_id(id :int):
	deviceId = id
	if deviceId > 0:
		InputManager.rumble(deviceId-GAMEPAD_DEVICE_ID_ADD, 0.25)

#	decal.visible = true
	
	avatar.scale = Vector3(2,1,2)
		
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(avatar, "scale", Vector3.ONE, 1.0)
	tween.finished.connect(_on_assign_device_complete)
	# warning-ignore:return_value_discarded
#	tween.interpolate_property(decal, "modulate", Color(2,2,2,1), PLAYER_COLORS[deviceId % PLAYER_COLORS.size()], 1.0, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
#	_bounce()
	print("%s device now %s" % [self, deviceId])
	SfxManager.enqueue3d(SoundType.PigGrunt, global_transform.origin)


func _on_assign_device_complete():
	if deviceId > 0:
		InputManager.stop_rumble(deviceId-GAMEPAD_DEVICE_ID_ADD)


func reset_device():
	deviceId = -10
#	decal.visible = false


func _get_input_action_prefix() -> String:
	if deviceId < 0:
		return ""
	elif deviceId < GAMEPAD_DEVICE_ID_ADD:
		return "desktop%s" % (deviceId + 1)
	else:
		return "joy%s" % (deviceId - GAMEPAD_DEVICE_ID_ADD + 1)


func _on_avatar_footstep():
	SfxManager.enqueue3d(SoundType.Footstep, global_position)
	_scuff_ground()


func _on_piggy_avatar_scuff():
	if hangTime < IN_AIR_THRSHOLD:
		_scuff_ground()
