extends KinematicBody

#code for player basic movement speeds
export var speed : float = 30.0
export var acceleration : float = 10.0
export var gravity : float = 1.0

#variables for player custom movement and jumping
var velocity : Vector3
var walkableAngle: float = 0.30
var fall_velocity : float
var canWalk: bool = true
#variable for player's current spawn position upon death
var direction : Vector3

var time = 0;


#AI specific code
var AI_STATE : float = 3.0
const AI_IDLE : float = 1.0
const AI_ATTACK : float = 2.0
const AI_RUN : float = 3.0
var canMove_AI : bool = true
onready var playerpos = get_node("../Player")
var timer : float = 3.0

#code to start physics process for game
func _physics_process(delta):
	#target = $"../../Pillar"
	if(AI_STATE == AI_IDLE):
		move_AI(delta)
	elif(AI_STATE == AI_ATTACK):
		fightPlayer(delta)
	elif(AI_STATE == AI_RUN):
		runAway(delta)

#main code that moves AI in an idle state
func move_AI(delta):
	timer += delta
	set_can_walk()
	if timer >= 2.0: #change directions every 2 seconds
		timer = 0.0
		direction = Vector3(random(), 0, random())
		while(test_move(self.transform, direction)): #make AI run into walls less frequently
			direction = Vector3(random(), 0, random())
		direction = direction.normalized()
		velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	handle_gravity()
	velocity.y = fall_velocity
	move_and_slide(velocity, Vector3.UP)
	

func random():
	randomize()
	return randi()%361-180 #selects a value between 180 through -180 which is all directions for xy axis


func fightPlayer(delta):
	direction = playerpos.transform.origin - self.transform.origin
	direction = direction.normalized()
	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	handle_gravity()
	velocity.y = fall_velocity
	move_and_slide(velocity, Vector3.UP)

func runAway(delta):
	direction = self.transform.origin - playerpos.transform.origin
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

