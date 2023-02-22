class_name HUDPlayer extends Control

var _points: int = 0
var _default_color: Color = Color.WHITE
var _name: String = "Piggy"
@onready var pointsLabel: Label = $Label


func _ready():
	pivot_offset = size / 2.0
	update_label_text()


func set_color(c: Color):
	modulate = c
	_default_color = c

func set_name(n: String):
	_name = n

func add_points(amount: int):
	_points += amount
	update_label_text()
	_flash()

func update_label_text():
	pointsLabel.text = str(_points) + "\n" + _name

func _flash():
	var tween_tint = create_tween()
	tween_tint.tween_property(self, "modulate", _default_color.lerp(Color.WHITE*2, 0.5), 0.1)
	tween_tint.tween_property(self, "modulate", _default_color, 0.5)
	tween_tint.play()
	
	var tween_scale = create_tween()
	tween_scale.tween_property(self, "scale", Vector2.ONE * 1.05, 0.1)
	tween_scale.tween_property(self, "scale", Vector2.ONE, 0.5)
	tween_scale.play()


func get_points() -> int:
	return _points
