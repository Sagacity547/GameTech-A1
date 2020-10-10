extends HBoxContainer

func _on_Control_gold(num):
	get_node("Label").set_text(str(num))
