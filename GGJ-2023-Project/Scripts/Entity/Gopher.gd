extends CharacterBody3D

enum {
	WANDER,
	PEEK
}


const SPEED = 4.0
const DURATION = 3.0

var _state :int = PEEK
var _wanderDir :Vector3

var timer = DURATION 
@onready var avatar = $Gopher


func _ready():
	_update_wander_direction()


func _physics_process(delta):
	timer -= delta
	var input_dir = Vector2.ZERO
	match _state:
		WANDER:
			# Get the input direction and handle the movement/deceleration.
			# As good practice, you should replace UI actions with custom gameplay actions.
			input_dir = Vector2(_wanderDir.x, _wanderDir.z)
			if timer <= 0:
				_state = PEEK
				timer = DURATION + randf()
				avatar.play_one_shot("Peak")
		PEEK:
			if timer <= 0:
				_state = WANDER
				_update_wander_direction()
				timer = DURATION + randf()
				
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
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