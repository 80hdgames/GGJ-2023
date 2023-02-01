class_name HUDPlayer extends Control

var _points :int = 0
@onready var pointsLabel :Label = $Label


func set_color(c :Color):
	modulate = c


func add_points(amount :int):
	_points += amount
	pointsLabel.text = str(_points)
