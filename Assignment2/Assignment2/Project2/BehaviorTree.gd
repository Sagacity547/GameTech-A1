extends CSGBox

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

# Called when the node enters the scene tree for the first time.
func _ready():
	attributes[0] = dispostions[get_rand_index()]
	attributes[1] = day_types[get_rand_index()]
	attributes[2] = body_types[get_rand_index()]
	set_tree()
	fight_or_not = set_reaction()
	
#called at initialization and after attributes changes
func set_reaction(): 
	#start from root and loop all attributes
	var node = behavior_tree
	var i = 0
	while node != null && i < attributes.size:
		if node.get_child(actions[0]) != null:
			return true
		node = node.get_child(attributes[i])
		i = i+1
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
