extends GPUParticles3D

const DURATION = 0.25
var timer = DURATION


func _on_piggy_scuff_ground():
	_emit()


func _process(delta):
	timer -= delta
	if timer <= 0:
		emitting = false
		set_process(false)


func _on_piggy_fart():
	_emit()


func _on_gopher_surface():
	_emit()


func _emit(add :float = 0.0):
	timer = DURATION + add
	set_process(true)
	emitting = true
