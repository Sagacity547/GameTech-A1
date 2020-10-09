extends KinematicBody

#code for player basic movement speeds
export var speed : float = 20
export var acceleration : float = 5
export var gravity : float = 0.98

#variables for player custom movement and jumping
var velocity : Vector3
var fall_velocity : float
var isJumping : bool = false
var isFlying : bool = false

#variable for player's current spawn position upon death
var spawnPoint = Vector3(-80.077, 6.14, -22.868) #coordinates of initial spawn point

#variables for Player GUI
var coins = 0

#get the camera
onready var cam = get_node("Camera")
#sensitivity variable that controls rotation in line 19
var sens = 0.2

#update movement and camera position based on Mouse action
func _input(event):
	if event is InputEventMouseMotion:
		#relative is the vector of how much mouse has moved
		var movement = event.relative
		cam.rotation.x += -deg2rad(movement.y * sens)
		#make sure the camera rotats upward and downward within 90%
		cam.rotation.x = clamp(cam.rotation.x, deg2rad(-90), deg2rad(90))
		rotation.y += -deg2rad(movement.x * sens)

#code to start non physics process for game
func _process(delta):
	if Input.is_action_just_pressed("jump") and !isFlying:
		var musicNode = $"Jump"
		musicNode.play()
		
		
		
#code to start physics process for game
func _physics_process(delta):
	move_player(delta)
	
	
#Player movement code
func move_player(delta):
	var direction = Vector3(0,0,0)
	
	if Input.is_action_pressed("move_right"):
		direction += transform.basis.x
	
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	
	if Input.is_action_pressed("move_backward"):
		direction += transform.basis.y
	
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.y
	
	direction = direction.normalized()
	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
		
	if is_on_floor():
		fall_velocity = -0.01
	else:
		fall_velocity = fall_velocity - gravity
		
	if Input.is_action_pressed("jump") &&  !isJumping && !Input.is_action_pressed("Fly"):
		fall_velocity = 15
		isJumping = true
	
	if Input.is_action_pressed("Fly") && Input.is_action_pressed("jump"):
		fall_velocity = 15
		isFlying = true
	
	if Input.is_action_just_released("Fly"):
		isFlying = false;
	
	if is_on_floor() && isJumping:
		isJumping = false
	
	velocity.y = fall_velocity
	velocity = move_and_slide(velocity, Vector3.UP)

#code for when player interacts with a coin object
func _on_Coin_body_entered(_body):
	var musicNode = $"Coin"
	musicNode.play()
	coins += 1
	print(coins)

#code for when player enters Lava
func _on_Lava_body_entered(_body):
	var musicNode = $"Lava"
	musicNode.play()
	self.set_translation(spawnPoint)

#test code for Player when entering a ledge
func _on_Starting_Ledge_body_entered(body):
	pass # Replace with function body.
