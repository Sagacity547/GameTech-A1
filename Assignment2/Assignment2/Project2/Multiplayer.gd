extends Node


# Declare member variables here. Examples:
var host = NetworkedMultiplayerENet.new()
var player_info = {}
var is_host = false
var SERVER_PORT = 6007
var SERVER_IP = "192.168.0.34" #Gavin's IP as of 10/16/2020
var NUM_PLAYERS = 1
var MAX_PLAYERS = 4
var spawn_points = [Vector3(-80.077, 6.14, -22.868), Vector3(-80.077, 26.14, -22.868), Vector3(-80.077, 6.14, -22.868), Vector3(-80.077, 6.14, -22.868)]
var unique_ids = ["1", "2", "3", "4",]
var is_connected = false

var my_id : int 
var other_id : int


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
	#initalize host
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("host_server") and !is_host:
		host.create_server(SERVER_PORT, MAX_PLAYERS)
		get_tree().network_peer = host
		is_host = true
		is_connected = true
		
		var id = get_tree().get_rpc_sender_id()
		var player = preload("res://Player.tscn").instance()
		player.set_translation(spawn_points[NUM_PLAYERS])
		player.set_name(str(id))
		player.set_network_master(get_tree().get_network_unique_id())
		player.get_child(0).get_child(2).current = true
		my_id = id
		#print(id)
		add_child(player)
		
	if Input.is_action_pressed("join_server") and !is_host and !is_connected:
		host.create_client(SERVER_IP, SERVER_PORT)
		get_tree().network_peer = host
		
		var id = get_tree().get_rpc_sender_id()
		var player = preload("res://Player.tscn").instance()
		player.set_translation(spawn_points[NUM_PLAYERS])
		player.set_name(str(id))
		player.set_network_master(id)
		player.get_child(0).get_child(2).current = true
		is_connected = true
		my_id = id
		print(id)
		add_child(player)
		

		
# Info we send to other players
var my_info = { name = "Johnson Magenta", favorite_color = Color8(255, 0, 255) }

func _player_connected(id):
	# Called on both clients and server when a peer connects. Send my info to it.
	rpc_id(id, "register_player", my_info)

func _player_disconnected(id):
	player_info.erase(id) # Erase player from info.

func _connected_ok():
	pass # Only called on clients, not server. Will go unused; not useful here.

func _server_disconnected():
	pass # Server kicked us; show error and abort.

func _connected_fail():
	pass # Could not even connect to server; abort.

remote func register_player(info):
	NUM_PLAYERS += 1
	var id = get_tree().get_rpc_sender_id()
	player_info[id] = info
	var player = preload("res://Player.tscn").instance()
	player.set_name(str(id))
	player.set_translation(spawn_points[NUM_PLAYERS])
	player.set_network_master(id)
	player.get_child(0).get_child(2).current = !is_host
	add_child(player)
	# Call function to update lobby UI here
