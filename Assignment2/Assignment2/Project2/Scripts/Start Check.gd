extends Area


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var position = Vector3(-75.032, 5.752, -15.685)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Start_Check_body_entered(body):
	if body.name == "Player":
		body.spawnPoint = position
