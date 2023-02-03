extends GPUParticles3D

const DURATION = 0.25
var timer = DURATION


func _on_piggy_scuff_ground():
	emit()


func _process(delta):
	timer -= delta
	if timer <= 0:
		emitting = false
		set_process(false)


func _on_piggy_fart():
	emit()


func _on_gopher_surface():
	emit()


func emit(add :float = 0.0):
	timer = DURATION + add
	set_process(true)
	emitting = true
