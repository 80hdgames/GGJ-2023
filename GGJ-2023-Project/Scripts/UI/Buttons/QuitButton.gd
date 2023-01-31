extends Button

const SoundType = SfxManager.SoundType


func _pressed():
	SfxManager.enqueue2d(SoundType.MenuCancel)
	SceneManager.go_to("res://Scenes/Quit.tscn")
	#get_tree().quit()
