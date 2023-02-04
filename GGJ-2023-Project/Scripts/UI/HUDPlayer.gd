class_name HUDPlayer extends Control

var _points :int = 0
var _defaultColor :Color = Color.WHITE
@onready var pointsLabel :Label = $Label


func _ready():
	pivot_offset = size/2.0


func set_color(c :Color):
	modulate = c
	_defaultColor = c


func add_points(amount :int):
	_points += amount
	pointsLabel.text = str(_points)
	_flash()


func _flash():
	var tweenTint = create_tween()
	tweenTint.tween_property(self, "modulate", _defaultColor.lerp(Color.WHITE*2, 0.5), 0.1)
	tweenTint.tween_property(self, "modulate", _defaultColor, 0.5)
	tweenTint.play()
	
	var tweenScale = create_tween()
	tweenScale.tween_property(self, "scale", Vector2.ONE * 1.05, 0.1)
	tweenScale.tween_property(self, "scale", Vector2.ONE, 0.5)
	tweenScale.play()
