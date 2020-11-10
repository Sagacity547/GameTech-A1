extends KinematicBody

#code for player basic movement speeds
export var speed : float = 10
export var acceleration : float = 5
export var gravity : float = 0.98

#variables for player custom movement and jumping
var velocity : Vector3
var walkableAngle: float = .30
var fall_velocity : float
var canWalk: bool = true
var is_connected: bool = false
#variable for player's current spawn position upon death
var spawnPoint = Vector3(-80.077, 6.14, -22.868) #coordinates of initial spawn point
var position : Vector3

var network_id : int
#variables for Player GUI
var time = 0;
var damage = 20.0
var health = 100.0

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
	if(health <= 0):
		gameOver()
	pass

#code to start physics process for game
func _physics_process(delta):
	move_player(delta)
	time += delta
	$HealthLabel.text = "Health " + str(health)


#Player movement code
func move_player(delta):
	set_can_walk()
	var direction = Vector3(0,0,0)
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
	
	move_and_slide(velocity, Vector3.UP)

#applies gravity to player and handles flying and jumping
func handle_gravity():
	# Gravity
	if is_on_floor():
		fall_velocity = -0.01 # prevents 
	else:
		fall_velocity = fall_velocity - gravity


func attack():
	pass

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

func gameOver():
	set_process(false)
	set_physics_process(false)
	$AnimationPlayer.play("GameOver")
	pass

