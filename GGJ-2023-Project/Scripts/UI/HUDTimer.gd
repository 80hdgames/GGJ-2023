extends Label

const HUD_NODE_GROUP = Constants.HUD_NODE_GROUP
const SoundType = SfxManager.SoundType
const MusicType = MusicManager.MusicType
const FRANTIC_TIME: int = 20
const TIMER_BOUNCE: float = 1.05

var _has_entered_frantic: bool = false
var _override_tween: Tween
@onready var _timer: Timer = $Timer
@onready var _startValue: float = _timer.wait_time
@onready var _last_value: float = _startValue

const TICK_COLOR = Color.WHITE * 2


func _ready():
#	pivot_offset = size/2.0
	
	# fly in
	var start_y = position.y
	position.y -= 120
	_override_tween = create_tween()
#	_override_tween.set_ease(Tween.EASE_IN_OUT)
	_override_tween.set_trans(Tween.TRANS_BOUNCE)
	_override_tween.tween_property(self, "position:y", start_y, 1.0)
	_override_tween.play()
	
	# setup and start _timer
	_timer.timeout.connect(_on_timeout)
	_timer.start()
	_update_label()
	pass


func _exit_tree():
	TimeManager.remove_timescale_mod(self)


func add_time(amount :float):
	if _timer.is_stopped() or is_equal_approx(amount, 0):
		return
	_timer.start(_timer.time_left + amount)
	_flash(Color.GREEN)
	_update_label()


func _on_timeout():
	TimeManager.remove_timescale_mod(self)
	get_tree().call_group(HUD_NODE_GROUP, "game_over")


func _process(_delta):
	var nextValue: int = ceili(_timer.time_left)
	if nextValue != _last_value:
		_tick()
		_update_label()
	
	
func _update_label():
	_last_value = ceili(_timer.time_left)
	text = str(_last_value)


func _tick():
	#check for transition to frantic/higher pitched track
	if not _has_entered_frantic and _last_value == FRANTIC_TIME:
		_has_entered_frantic = true
		MusicManager.push(MusicType.FranticTimeAccent)
		MusicManager.enqueue(MusicType.Gameplay_Frantic)
		TimeManager.add_timescale_mod(self, 1.5)
	
	
	if _override_tween.is_running():
		return
		
	var tween = create_tween()
	tween.tween_property(self, "self_modulate", Color.WHITE * 2, 0.1)
	tween.tween_property(self, "self_modulate", _get_default_color(), 0.75)
	tween.play()
	
	var tween_scale = create_tween()
	tween_scale.tween_property(self, "scale", Vector2.ONE * _get_target_bounce(), 0.25)
	tween_scale.tween_property(self, "scale", Vector2.ONE, 0.5)
	tween_scale.play()


func _flash(_shineColor: Color):
	_override_tween = create_tween()
	_override_tween.tween_property(self, "self_modulate", _shineColor, 0.1)
	_override_tween.tween_property(self, "self_modulate", _get_default_color(), 0.75)
	_override_tween.play()
	
	var tween_scale = create_tween()
	tween_scale.tween_property(self, "scale", Vector2.ONE * _get_target_bounce(), 0.25)
	tween_scale.tween_property(self, "scale", Vector2.ONE, 0.5)
	tween_scale.play()


func get_time_left() -> float:
	return _timer.time_left


func _get_default_color(c: Color = Color.TRANSPARENT) -> Color:
	if c != Color.TRANSPARENT:
		return c
#	if _last_value < _startValue/4:
#		return Color.RED
#	elif _last_value < _startValue/3:
#		return Color.ORANGE
#	elif _last_value < _startValue/2:
#		return Color.YELLOW
	if _last_value < FRANTIC_TIME:
		return Color.ORANGE
	else:
		return Color.WHEAT


func _get_target_bounce() -> float:
	return (clamp(_last_value / _startValue, 0.0, 1.0)) * TIMER_BOUNCE
