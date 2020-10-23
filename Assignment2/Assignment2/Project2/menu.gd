extends Control

func _ready():
	$title.show()
	$input.hide()
	$instructions.hide()

func _on_Button_pressed():
	$title.hide()
	$input.show()

func _on_Button2_pressed():
	$title.hide()
	$input.show()

func _on_Button3_pressed():
	$title.hide()
	$instructions.show()

func _on_Button4_pressed():
	$title.show()
	$input.hide()

func _on_Button5_pressed():
	$instructions.hide()
	$title.show()
