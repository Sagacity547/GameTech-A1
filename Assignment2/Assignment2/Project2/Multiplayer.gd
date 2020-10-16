extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var player = NetworkedMultiplayerENet.new()
var player_info = {}
var is_host = false
var SERVER_PORT = 500
var SERVER_IP = "192.168.0.34" #Gavin's IP as of 10/16/2020
var MAX_PLAYERS = 4

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("host_server"):
		
		player.create_server(SERVER_PORT, MAX_PLAYERS)
		get_tree().network_peer = player
		is_host = true
		
	if Input.is_action_pressed("join_server"):
		player.create_client(SERVER_IP, SERVER_PORT)
		get_tree().network_peer = player
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
	# Get the id of the RPC sender.
	var id = get_tree().get_rpc_sender_id()
	# Store the info
	player_info[id] = info

	# Call function to update lobby UI here
