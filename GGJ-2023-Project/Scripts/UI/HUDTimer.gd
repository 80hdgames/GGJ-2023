extends Label

const HUD_NODE_GROUP = Constants.HUD_NODE_GROUP
const SoundType = SfxManager.SoundType
const MusicType = MusicManager.MusicType
const FRANTIC_TIME = 20
const TIMER_BOUNCE = 1.05


@onready var timer :Timer = $Timer
@onready var _startValue :float = timer.wait_time
@onready var lastValue :float = _startValue


func _ready():
	timer.timeout.connect(_on_timeout)
	timer.start()
	_update_label()
	pass


func _on_timeout():
	get_tree().call_group(HUD_NODE_GROUP, "game_over")


func _process(_delta):
	_update_label()
	
	
func _update_label():
	var nextValue :int = ceili(timer.time_left)
	if nextValue != lastValue:
		_flash()
	lastValue = ceili(timer.time_left)
	text = str(lastValue)


func _flash():
	if lastValue == FRANTIC_TIME:
		MusicManager.push(MusicType.FranticTimeAccent)
		MusicManager.enqueue(MusicType.Gameplay_Frantic)
	
	var tween = create_tween()
	tween.tween_property(self, "self_modulate", _get_target_color() * 1.5, 0.25)
	tween.tween_property(self, "self_modulate", _get_target_color(), 0.5)
	tween.play()
	
	var tweenScale = create_tween()
	tweenScale.tween_property(self, "scale", Vector2.ONE * _get_target_bounce(), 0.25)
	tweenScale.tween_property(self, "scale", Vector2.ONE, 0.5)
	tweenScale.play()


func _get_target_color() -> Color:
#	if lastValue < _startValue/4:
#		return Color.RED
#	elif lastValue < _startValue/3:
#		return Color.ORANGE
#	elif lastValue < _startValue/2:
#		return Color.YELLOW
	if lastValue < FRANTIC_TIME:
		return Color.ORANGE
	else:
		return Color.WHEAT


func _get_target_bounce() -> float:
	return (clamp(lastValue / _startValue, 0.0, 1.0)) * TIMER_BOUNCE
