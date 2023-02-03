extends Label

const HUD_NODE_GROUP = Constants.HUD_NODE_GROUP
const SoundType = SfxManager.SoundType
const MusicType = MusicManager.MusicType
const FRANTIC_TIME :int = 20
const TIMER_BOUNCE :float = 1.05


var hasEnteredFrantic :bool = false
var overrideTween :Tween
@onready var timer :Timer = $Timer
@onready var _startValue :float = timer.wait_time
@onready var lastValue :float = _startValue

const TICK_COLOR = Color.WHITE * 2


func _ready():
	# fly in
	var startY = position.y
	position.y -= 120
	overrideTween = create_tween()
#	overrideTween.set_ease(Tween.EASE_IN_OUT)
	overrideTween.set_trans(Tween.TRANS_BOUNCE)
	overrideTween.tween_property(self, "position:y", startY, 1.0)
	overrideTween.play()
	
	# setup and start timer
	timer.timeout.connect(_on_timeout)
	timer.start()
	_update_label()
	pass


func _exit_tree():
	TimeManager.remove_timescale_mod(self)


func add_time(amount :float):
	if timer.is_stopped() or is_equal_approx(amount, 0):
		return
	timer.start(timer.time_left + amount)
	_flash(Color.GREEN)
	_update_label()


func _on_timeout():
	get_tree().call_group(HUD_NODE_GROUP, "game_over")


func _process(_delta):
	var nextValue :int = ceili(timer.time_left)
	if nextValue != lastValue:
		_tick()
		_update_label()
	
	
func _update_label():
	lastValue = ceili(timer.time_left)
	text = str(lastValue)


func _tick():
	#check for transition to frantic/higher pitched track
	if not hasEnteredFrantic and lastValue == FRANTIC_TIME:
		hasEnteredFrantic = true
		MusicManager.push(MusicType.FranticTimeAccent)
		MusicManager.enqueue(MusicType.Gameplay_Frantic)
		TimeManager.add_timescale_mod(self, 1.5)
	
	
	if overrideTween.is_running():
		return
		
	var tween = create_tween()
	tween.tween_property(self, "self_modulate", Color.WHITE*2, 0.1)
	tween.tween_property(self, "self_modulate", _get_default_color(), 0.75)
	tween.play()
	
	var tweenScale = create_tween()
	tweenScale.tween_property(self, "scale", Vector2.ONE * _get_target_bounce(), 0.25)
	tweenScale.tween_property(self, "scale", Vector2.ONE, 0.5)
	tweenScale.play()


func _flash(_shineColor :Color):
	overrideTween = create_tween()
	overrideTween.tween_property(self, "self_modulate", _shineColor, 0.1)
	overrideTween.tween_property(self, "self_modulate", _get_default_color(), 0.75)
	overrideTween.play()
	
	var tweenScale = create_tween()
	tweenScale.tween_property(self, "scale", Vector2.ONE * _get_target_bounce(), 0.25)
	tweenScale.tween_property(self, "scale", Vector2.ONE, 0.5)
	tweenScale.play()


func get_time_left() -> float:
	return timer.time_left


func _get_default_color(c :Color = Color.TRANSPARENT) -> Color:
	if c != Color.TRANSPARENT:
		return c
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
