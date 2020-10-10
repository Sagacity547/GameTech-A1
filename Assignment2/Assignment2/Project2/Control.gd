extends Control

signal gold(num)

#func _ready():
#	emit_signal("gold",0)

func gold_changed(value):
	emit_signal("gold",value)


func _on_Player_coin(value):
	gold_changed(value)
