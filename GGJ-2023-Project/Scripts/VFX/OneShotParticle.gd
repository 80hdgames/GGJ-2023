extends GPUParticles3D

const DURATION = 0.25
var timer = DURATION


func _on_piggy_scuff_ground():
	timer = DURATION
	set_process(true)
	emitting = true


func _process(delta):
	timer -= delta
	if timer <= 0:
		emitting = false
		set_process(false)
