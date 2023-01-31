extends CharacterBody3D


const SPEED = 5.0
const GRIP = 0.25
const JUMP_VELOCITY = 4.5
const TITLE_SCREEN_SCENE = Constants.TITLE_SCREEN_SCENE
const MAX_BOOST = 1
const BOOST_SPEED = 4
const BOOST_RECHARGE_RATE = 0.01
const BOOST_BURN_RATE = 0.02

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var boostCharge = MAX_BOOST
var isBoosting = false

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		SceneManager.go_to(TITLE_SCREEN_SCENE)

func can_boost():
	return boostCharge >= 1 and !isBoosting
	

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_pressed("desktop1_boost") and can_boost():
		isBoosting = true
		
	if isBoosting:
		boostCharge = max(0, boostCharge - BOOST_BURN_RATE)
		if boostCharge <= 0:
			isBoosting = false
	else:
		boostCharge = min(boostCharge + BOOST_RECHARGE_RATE, MAX_BOOST)

	var boost = BOOST_SPEED if isBoosting else 0

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = move_toward(velocity.x, direction.x * (SPEED + boost), GRIP)
		velocity.z = move_toward(velocity.z, direction.z * (SPEED + boost), GRIP)
	else:
		velocity.x = move_toward(velocity.x, 0, GRIP)
		velocity.z = move_toward(velocity.z, 0, GRIP)

	move_and_slide()
