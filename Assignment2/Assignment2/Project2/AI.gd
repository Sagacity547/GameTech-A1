extends KinematicBody

#code for player basic movement speeds
export var speed : float = 20
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

var time = 0;

#get the camera
onready var cam = get_node("Camera")
#sensitivity variable that controls rotation in line 19
var sens = 0.7

#code to start non physics process for game
func _process(delta):
	pass

#code to start physics process for game
func _physics_process(delta):
	move_ai(delta)
	
remote func _set_position(pos):
	global_transform.origin = pos

#Player movement code
func move_ai(delta):
	set_can_walk()
	var direction = Vector3(0,0,0)
	

#applies gravity to player and handles flying and jumping
func handle_gravity():
	# Gravity
	if is_on_floor():
		fall_velocity = -0.01 # prevents 
	else:
		fall_velocity = fall_velocity - gravity


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

