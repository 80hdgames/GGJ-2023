extends Button

const SoundType = SfxManager.SoundType


func _pressed():
	SfxManager.enqueue2d(SoundType.MenuCancel)
	get_tree().quit()
