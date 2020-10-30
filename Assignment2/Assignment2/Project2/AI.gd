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
#variable for player's current spawn position upon death
var position : Vector3
var direction : Vector3

var time = 0;


#AI specific code
var AI_STATE : float = 1.0
const AI_IDLE : float = 1.0
const AI_ATTACK : float = 2.0
var canMove_AI : bool = true

#code to start physics process for game
func _physics_process(delta):
	move_AI(delta)

func ai_get_direction():
	return target.position - self.position

func move_AI(delta):
	var direction = ai_get_direction()
	var motion = direction.normalized() * speed
	move_and_slide(motion)

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

