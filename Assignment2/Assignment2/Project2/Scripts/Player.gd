extends KinematicBody

#code for player basic movement speeds
export var speed : float = 20
export var acceleration : float = 5
export var gravity : float = 0.98

#variables for player custom movement and jumping
var velocity : Vector3
var walkableAngle: float = .30
var fall_velocity : float
var isJumping : bool = false
var isFlying : bool = false
var isOnEdge: bool = false
var canWalk: bool = true
var hasDashed: bool = false
var is_connected: bool = false
#variable for player's current spawn position upon death
var spawnPoint = Vector3(-80.077, 6.14, -22.868) #coordinates of initial spawn point

#variables for Player GUI
var coins = 2
var gas = 1000
var time = 0;

#get the camera
onready var cam = get_node("Camera")
#sensitivity variable that controls rotation in line 19
var sens = 0.7

#update movement and camera position based on Mouse action
func _input(event):
	if event is InputEventMouseMotion:
		#relative is the vector of how much mouse has moved
		var movement = event.relative
		cam.rotation.x += -deg2rad(movement.y * sens)
		rotation.y += -deg2rad(movement.x * sens)

#code to start non physics process for game
func _process(delta):
	if Input.is_action_just_pressed("jump") and !isFlying:
		var musicNode = $"Jump"
		musicNode.play()
		
		
#code to start physics process for game
func _physics_process(delta):
	move_player(delta)
	#time += delta
	#$TimeLabel.text = "Time: " + str(stepify(time, 1.0))
	
remote func _set_position(pos):
	global_transform.origin = pos

#Player movement code
func move_player(delta):
	set_can_walk()
	var direction = Vector3(0,0,0)
	if !isOnEdge:
		if canWalk : 
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
		
		handle_gravity()
	
		velocity.y = fall_velocity
		
		if is_network_master(): # Multiplayer additon ---> we don't want the other person controlling you
			velocity = move_and_slide(velocity, Vector3.UP)
	else : # ledge hang edge case, freeze the player on the edge until the pop off with E
		if Input.is_action_pressed("ledge_hang"):
			isOnEdge = false
			velocity = Vector3(0,0,0)
	#Multiplayer addition ---> we need the transformations to show on both sides
	rpc_unreliable("_set_position", global_transform.origin)
			

#applies gravity to player and handles flying and jumping
func handle_gravity():
	# Gravity
	if is_on_floor():
		fall_velocity = -0.01 # prevents 
	else:
		fall_velocity = fall_velocity - gravity
	
	# Standard Jump
	if Input.is_action_pressed("jump") &&  !isJumping && !Input.is_action_pressed("Fly"):
		fall_velocity = 15
		isOnEdge = false
		isJumping = true
		
	# Flying
	if Input.is_action_pressed("Fly") && Input.is_action_pressed("jump") && gas > 0:
		fall_velocity = 15
		gas -= 5
		$GasLabel.text = "Gas: " + str(gas)
		isOnEdge = false
		isFlying = true
	
	# Saving Dash
	if Input.is_action_pressed("saving_dash") && !hasDashed:
		hasDashed = true
		fall_velocity += 70
	
	#Stopped Flying
	if Input.is_action_just_released("Fly"):
		isFlying = false;
	
	#Stopped Jumping
	if is_on_floor() && isJumping:
		isJumping = false


#Handles checking the walkable angle 
func set_can_walk():
	if Input.is_action_pressed("walkable_angle_up") && walkableAngle < .9:
		walkableAngle = walkableAngle + .1
	if Input.is_action_pressed("walkable_angle_down") && walkableAngle > .1:
		walkableAngle = walkableAngle - .1
	
	if get_slide_count() > 0:
		var collider = get_slide_collision(0)
		var norm = Vector3(collider.normal)
		# we need to check the x to get the angle 
		# cannot walk down too steep of an angle?? 
		if abs(norm.x) > walkableAngle:
			canWalk = false
		else: 
			canWalk = true

#code for when player interacts with a coin object
func _on_Coin_body_entered(_body):
	var musicNode = $"Coin"
	musicNode.play()
	coins += 1
	$CoinLabel.text = "Coins: " + str(coins)
	print(coins)

#code for when player enters Lava
func _on_Lava_body_entered(_body):
	var musicNode = $"Lava"
	musicNode.play()
	gas = 1000
	hasDashed = false
	isJumping = false
	isFlying = false
	if coins != 0:
		coins -= 1
	$GasLabel.text = "Gas: " + str(gas)
	$CoinLabel.text = "Coins: " + str(coins)
	self.set_translation(spawnPoint)
	
func handle_ledge_hang():
	pass

#test code for Player when entering a ledge
# When a player enters the collison shape we set isOnEdge to true 
func _on_Starting_Ledge_body_entered(body):
	if body.get_name() == "Player":
		isOnEdge = true

#test code for Player when entering a ledge
#When a player enters the collison shape we set isOnEdge to true
func _on_Starting_ledge_exited(body):
	if body.get_name() == "Player":
		isOnEdge = false

func _on_Gas_body_entered(_body):
	var musicNode = $"Gas"
	musicNode.play()
	if gas < 1000:
		gas += 500
		if gas > 1000:
			gas = 1000
	$GasLabel.text = "Gas: " + str(gas)
	pass # Replace with function body.


func _on_Game_Over_body_entered(_body):
	set_process(false)
	set_physics_process(false)
	$AnimationPlayer.play("GameOver")
	$CanvasLayer2/EndTimeLabel.text = "Time: " + str(stepify(time, 1))
	$CanvasLayer2/EndCoinLabel.text = "Coins: " + str(coins)
