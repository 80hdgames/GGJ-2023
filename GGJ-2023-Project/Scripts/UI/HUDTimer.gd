extends Label

@onready var timer :Timer = $Timer
var lastValue :int


func _ready():
	timer.timeout.connect(_on_timeout)
	timer.start()
	_update_label()
	pass


func _on_timeout():
	print("GAME OVER!")
	pass


func _process(_delta):
	_update_label()
	
	
func _update_label():
	lastValue = ceili(timer.time_left)
	text = str(lastValue)
