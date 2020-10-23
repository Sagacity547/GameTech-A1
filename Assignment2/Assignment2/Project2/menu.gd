extends Control

func _ready():
	$title.show()
	$newgame.hide()
	$joingame.hide()
	$instructions.hide()

func _on_Button_pressed():
	$title.hide()
	$newgame.show()

func _on_Button2_pressed():
	$title.hide()
	$joingame.show()

func _on_Button3_pressed():
	$title.hide()
	$instructions.show()

func _on_Button4_pressed():
	$title.show()
	$joingame.hide()

func _on_Button5_pressed():
	$instructions.hide()
	$title.show()

func _on_Button8_pressed():
	$newgame.hide()
	$joingame.show()

func _on_Button6_pressed():
	$joingame.hide()

func _on_Button7_pressed():
	$newgame.hide()
