extends Object


class_name ZNode

# Declare member variables here. Examples:
var text : String
var child_left : ZNode # ALWAYS SET
var child_right : ZNode # ALWAYS SET

# Called when the node enters the scene tree for the first time.
func _init(txt)->void:
	text = txt

func set_text(input):
	text = input
	
func set_left(child):
	child_left = child
	
func set_right(child):
	child_right = child

# ONLY METHOD FOR USE BY EVAN
# Send it the text label you are looking for and it will give you the ZNode object. Use this to parse the tree
# Ex: root.get_child("Aggresive").text = "Aggressive" 
# returns the ZNode object OR zero if it cannot find a child with the given label
func get_child(txt):
	if child_left.text == txt :
		return child_left
	else:
		if child_right.text == txt :
			return child_right
		else : 
			return null
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
#	 pass
