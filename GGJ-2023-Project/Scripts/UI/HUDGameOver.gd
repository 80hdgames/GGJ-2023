extends Control

@onready var label = $VBoxContainer/HUDWinner


func display_results(_winners: Array):
	show()
#	if _winners.is_empty() or _winners.has(null) or _winners.size() > 1:
#		label.text = "DRAW!?"
#	else:
#		label.text = "%s Wins!" % _winners[0].name
#	$VBoxContainer.show()
	pass
