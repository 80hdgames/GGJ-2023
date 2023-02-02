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
const GAMEPAD_DEVICE_ID_ADD = Constants.GAMEPAD_DEVICE_ID_ADD
const PLAYER_COLORS = Constants.PLAYER_COLORS

var deviceId :int = -10

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var boostCharge = MAX_BOOST
var isBoosting :bool = false
var inputDir :Vector2 = Vector2.ZERO
@onready var avatar :Avatar = $Piggy_Avatar


func can_boost():
	return boostCharge >= 1 and !isBoosting


func activate_boost():
	isBoosting = true
	SfxManager.enqueue3d(SoundType.PigSqueal, global_transform.origin)
	avatar.play("Dash")
	# TODO: animation, particle effect, etc.


func _unhandled_input(_event :InputEvent):
	if _event.is_action_pressed("ui_cancel"):
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
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
#	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
#		_jump()
#
#	if Input.is_action_just_pressed("desktop1_boost") and can_boost():
#		activate_boost()

	if isBoosting:
		boostCharge = max(0, boostCharge - BOOST_BURN_RATE * delta)
		if boostCharge <= 0:
			isBoosting = false
	else:
		boostCharge = min(boostCharge + BOOST_RECHARGE_RATE * delta, MAX_BOOST)

	var boost = BOOST_SPEED if isBoosting else 0

	# Get the input direction and handle the movement/deceleration.
#	inputDir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	_process_move_input()
	var direction = (transform.basis * Vector3(inputDir.x, 0, inputDir.y)).normalized()
	if direction:
		velocity.x = move_toward(velocity.x, direction.x * (SPEED + boost), GRIP)
		velocity.z = move_toward(velocity.z, direction.z * (SPEED + boost), GRIP)
	else:
		velocity.x = move_toward(velocity.x, 0, GRIP)
		velocity.z = move_toward(velocity.z, 0, GRIP)

	move_and_slide()
	_update_animation(direction)


func _update_animation(direction :Vector3):
	if direction != Vector3.ZERO:
		var smoothedDirection = avatar.global_transform.basis.z.slerp(direction, TURN_SPEED)
		avatar.look_at(global_transform.origin - smoothedDirection)
		var facingDiff = avatar.global_transform.basis.z.dot(direction)
		var skidStrength = 1 - ((facingDiff + 1) / 2)
		# TODO: dirt/dust particles when piggies are skidding
		# skidStrength is 0 when piggies are facing the direction they're moving,
		# and 1 when piggies are facing opposite to their movement.
		# We can scale effect strength based on this value!

	if not isBoosting and is_on_floor():
		avatar.play("Run" if direction != Vector3.ZERO else "Idle")


func _jump():
	avatar.play_one_shot("Jump")
	# TODO: poof vfx
	velocity.y = JUMP_VELOCITY
	SfxManager.enqueue3d(SoundType.PigGrunt, global_transform.origin)


func _process_move_input():
	if deviceId < 0:
		return
		
	inputDir = Input.get_vector("%s_left" % _get_input_action_prefix(), \
	"%s_right" % _get_input_action_prefix(), \
	"%s_up" % _get_input_action_prefix(), \
	"%s_down" % _get_input_action_prefix())


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

