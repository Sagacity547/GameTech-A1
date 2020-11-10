extends KinematicBody

#code for player basic movement speeds
export var speed : float = 10.0
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

#Combat code
var damage : float = 15.0
var health : float = 100.0


#AI specific code
var AI_STATE : float = 2.0
const AI_IDLE : float = 1.0
const AI_ATTACK : float = 2.0
const AI_RUN : float = 3.0
var canMove_AI : bool = true
onready var player = get_node("../Player")
var timer : float = 3.0     #time till AI changes directions during idle
var taskTimer : float       #time before doing a task
var tasking : float = 25.0  #time spend doing a task

#Task nodes
var taskArray
onready var task1 = get_node("../Area/Pillar")
onready var task2 = get_node("../Area/Pillar2")
onready var task3 = get_node("../Area/Pillar3")
onready var task4 = get_node("../Area/Pillar4")

func _ready():
	taskArray = [task1.transform.origin, task2.transform.origin]
	taskRandom()
	selectTask()

func _process(_delta):
	pass

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
	taskTimer -= delta
	set_can_walk()
	#task
	if taskTimer <= 0.0 && tasking > 0.0:
		tasking -= delta
		task(delta)
		if tasking <= 0.0:
			taskRandom()
			tasking = 25.0
			selectTask()
	elif timer >= 2.0: #change directions every 2 seconds
		timer = 0.0
		direction = Vector3(random(), 0, random())
		while(test_move(self.transform, direction)): #make AI run into walls less frequently
			direction = Vector3(random(), 0, random())
		direction = direction.normalized()
		velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	handle_gravity()
	velocity.y = fall_velocity
	move_and_slide(velocity, Vector3.UP)
	

#set a random interval of time between 15 and 180 seconds before going off to complete task
func taskRandom():
	randomize()
	taskTimer = randi()%75 + 15

#select a task to go to when tasking
func selectTask():
	taskArray.shuffle()

#have AI go to task position
func task(delta):
	direction = taskArray.front() - self.transform.origin
	direction = direction.normalized()
	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)

func random():
	randomize()
	return randi()%361-180 #selects a value between 180 through -180 which is all directions for xy axis

var attackTimer : float = 10.0
func fightPlayer(delta):
	attackTimer -= delta
	if(attackTimer <= 0.0 && self.is_on_wall()):
		attackTimer = 5.0
		attack()
	direction = player.transform.origin - self.transform.origin
	direction = direction.normalized()
	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	handle_gravity()
	velocity.y = fall_velocity
	move_and_slide(velocity, Vector3.UP)

func runAway(delta):
	direction = self.transform.origin - player.transform.origin
	direction = direction.normalized()
	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	handle_gravity()
	velocity.y = fall_velocity
	move_and_slide(velocity, Vector3.UP)

func attack():
	player.health -= damage
	pass


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

