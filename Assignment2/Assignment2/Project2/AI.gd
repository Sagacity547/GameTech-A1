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
var AI_STATE : float = 1.0
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
	#idle AI
	taskArray = [task1.transform.origin, task2.transform.origin]
	taskRandom()
	selectTask()
	
	#Action AI
	attributes[0] = dispostions[get_rand_index()]
	attributes[1] = day_types[get_rand_index()]
	attributes[2] = body_types[get_rand_index()]
	set_tree()
	fight_or_not = set_reaction()

func _process(delta):
	if(health <= 0):
		queue_free()
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

var attackTimer : float = 2.0
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

func _on_AI_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed == true:
		health -= player.damage
		if fight_or_not:
			var newMaterial = SpatialMaterial.new()
			newMaterial.albedo_color = Color(0.92, 0.19, 0.13, 1.0)
			self.get_child(1).material_override = newMaterial
			AI_STATE = 2.0
		else:
			var newMaterial = SpatialMaterial.new()
			newMaterial.albedo_color = Color(0.92, 0.92, 0.01, 1.0)
			self.get_child(1).material_override = newMaterial
			AI_STATE = 3.0
	pass # Replace with function body.


#Decision Tree Code
#constants
const dispostions = ["Aggressive", "Docile"]
const day_types = ["Bad", "Good"]
const body_types = ["Big", "Small"]
const actions = ["Fight", "Run"]

# Declare member variables here. Examples:
var attributes = ["Disposition","Day Type","Body Type"]
var current_action = ""
var behavior_tree
var fight_or_not

#called at initialization and after attributes changes
func set_reaction(): 
	#start from root and loop all attributes
	var node = behavior_tree
	var i = 0
	while node != null && i < attributes.size():
		node = node.get_child(attributes[i])
	#check if it's fight
	if node != null && node.get_child(actions[0]) != null:
		return true
	else:
		return false


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_tree():
	var run = ZNode.new(actions[1])
	var fight = ZNode.new(actions[0])
	
	# Built Upside Down
	var small_build = ZNode.new(body_types[1])
	small_build.set_left(run)
	small_build.set_right(run)
	
	var big_build = ZNode.new(body_types[0])
	big_build.set_left(fight)
	big_build.set_right(fight)
	
	var aggro_good_day = ZNode.new(day_types[1])
	aggro_good_day.set_left(small_build)
	aggro_good_day.set_right(big_build)
	
	var docile_bad_day = ZNode.new(day_types[0])
	docile_bad_day.set_left(small_build)
	docile_bad_day.set_right(big_build)
	
	var docile_good_day = ZNode.new(day_types[1])
	docile_good_day.set_left(run)
	docile_good_day.set_right(run)
	
	var aggro_bad_day = ZNode.new(day_types[0])
	aggro_bad_day.set_left(fight)
	aggro_bad_day.set_right(fight)
	
	var dispostion_docile = ZNode.new(dispostions[1])
	dispostion_docile.set_left(docile_good_day)
	dispostion_docile.set_right(docile_bad_day)
	
	var dispostion_aggro = ZNode.new(dispostions[0])
	dispostion_aggro.set_left(aggro_good_day)
	dispostion_aggro.set_right(aggro_bad_day)
	
	behavior_tree = ZNode.new("root")
	behavior_tree.set_left(dispostion_docile)
	behavior_tree.set_right(dispostion_aggro)

	
# gets 0 or 1, ugly but gets the job done
func get_rand_index():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	return rng.randi_range(0, 1)
