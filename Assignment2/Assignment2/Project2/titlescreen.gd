extends Control

func _ready():
		$Button.connect("pressed",self,"_button_pressed",[$Button.scene])
		$controlbutton.connect("pressed",self,"_button_pressed",[$controlbutton.scene])

func _button_pressed(scene):
	get_tree().change_scene(scene)
