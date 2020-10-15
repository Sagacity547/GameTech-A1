#include "Player.h"

using namespace godot;

void Player::_register_methods() {
	register_method("_init", &Player::_init);
	register_method("_input", &Player::_ready);
	register_method("_process", &Player::_process);
	register_method("_physics_process", &Player::_physics_process);
	register_method("move_player", &Player::move_player);
	register_method("handle_gravity", &Player::handle_gravity);
	register_method("set_can_walk", &Player::set_can_walk);

	register_method("_on_Coin_body_entered", &Player::_on_Coin_body_entered);
	register_method("_on_Lava_body_entered", &Player::_on_Lava_body_entered);
	register_method("handle_ledge_hang", &Player::handle_ledge_hang);
	register_method("_on_Starting_Ledge_body_entered", &Player::_on_Starting_Ledge_body_entered);
	register_method("_on_Starting_ledge_exited", &Player::_on_Starting_ledge_exited);
	register_method("_on_Gas_body_entered", &Player::_on_Gas_body_entered);

	//code for player basic movement speeds
	register_property("acceleration", &Player::acceleration, 5);
	register_property("speed", &Player::speed, 20);
	register_property("gravity", &Player::gravity, 0.98);

	//variables for player custom movement and jumping
	register_property("velocity", &Player::velocity, Vector3);
	register_property("walkableAngle", &Player::walkableAngle, 0.3);
	register_property("fall_velocity", &Player::fall_velocity, 0);
	register_property("isJumping", &Player::isJumping, false);
	register_property("isFlying", &Player::isFlying, false);
	register_property("isOnEdge", &Player::isOnEdge, false);
	register_property("canWalk", &Player::canWalk, true);
	register_property("hasDashed", &Player::hasDashed, false);
	//variable for player's current spawn position upon death
	register_property("spawnPoint", &Player::spawnPoint, Vector3(-80.077, 6.14, -22.868)); //coordinates of initial spawn point

	
	//variables for Player GUI
	register_property("coins", &Player::coin, 0);
	register_property("gas", &Player::gas, 1000);

	//get the camera
	onready register_property("cam", &Player::cam, get_node("Camera"));
	//sensitivity variable that controls rotation line 19
	register_property("sens", &Player::sens, 0.7);
}

void Player::_init() {

}

//update movement and camera position based on Mouse action
void Player::_input(event) {
	if (event is InputEventMouseMotion) {
		//relative is the vector of how much mouse has moved
		var movement = event.relative
		cam.rotation.x += -deg2rad(movement.y * sens)
		rotation.y += -deg2rad(movement.x * sens)
	}
}

//code to start non physics process for game
void Player::_process(float delta) {
	if (Input.is_action_just_pressed("jump") and !isFlying) {
		var musicNode = $ "Jump" musicNode.play()
	}
}

//code to start physics process for game
void Player::_physics_process(float delta) {
	move_player(delta);
}
	
//Player movement code
void Player::move_player(float delta){
	set_can_walk();
	var direction = Vector3(0, 0, 0);
	if (!isOnEdge) {
		if (canWalk){ 
			if (Input.is_action_pressed("move_right"))
				direction += transform.basis.x;
	
			if (Input.is_action_pressed("move_left"))
				direction -= transform.basis.x;
	
			if (Input.is_action_pressed("move_backward"))
				direction += transform.basis.y;
	
			if (Input.is_action_pressed("move_forward"))
				direction -= transform.basis.y;
	
		direction = direction.normalized();
		velocity = velocity.linear_interpolate(direction * speed, acceleration * delta);
		
		handle_gravity();
	
		velocity.y = fall_velocity;
		velocity = move_and_slide(velocity, Vector3.UP);
		}
	} else { // ledge hang edge case, freeze the player on the edge until the pop off with E
		if (Input.is_action_pressed("ledge_hang")) {
			isOnEdge = false;
			velocity = Vector3(0, 0, 0);
		}
	}
}

//applies gravity to player and handles flying and jumping
void Player::handle_gravity() {
	//Gravity
	if (is_on_floor())
		fall_velocity = -0.01 #prevents;
	else
		fall_velocity = fall_velocity - gravity;
	
	//Standard Jump
	if (Input.is_action_pressed("jump") && !isJumping && !Input.is_action_pressed("Fly")) {
		fall_velocity = 15;
		isOnEdge = false;
		isJumping = true;
	}
		
	//Flying
	if (Input.is_action_pressed("Fly") && Input.is_action_pressed("jump") && gas > 0) {
		fall_velocity = 15;
		gas -= 5;
		$GasLabel.text = "Gas: " + str(gas);
		isOnEdge = false;
		isFlying = true;
	}

	//Saving Dash
	if (Input.is_action_pressed("saving_dash") && !hasDashed) {
		hasDashed = true;
		fall_velocity += 70;
	}

	//Stopped Flying
	if (Input.is_action_just_released("Fly"))
		isFlying = false;
	
	//Stopped Jumping
	if (is_on_floor() && isJumping)
		isJumping = false;
}

//Handles checking the walkable angle 
void Player::set_can_walk() {
	if (Input.is_action_pressed("walkable_angle_up") && walkableAngle < .9)
		walkableAngle = walkableAngle + .1;
	if (Input.is_action_pressed("walkable_angle_down") && walkableAngle > .1)
		walkableAngle = walkableAngle - .1;
	
	if (get_slide_count() > 0) {
		var collider = get_slide_collision(0);
		var norm = Vector3(collider.normal);
		//we need to check the x to get the angle 
		//cannot walk down too steep of an angle?? 
		if (abs(norm.x) > walkableAngle)
			canWalk = false;
		else
			canWalk = true;
	}
}
	
//code for when player interacts with a coin object
void Player::_on_Coin_body_entered(_body) {
	var musicNode = $ "Coin";
	musicNode.play();
	coins += 1;
	$CoinLabel.text = "Coins: " + str(coins);
	print(coins);
}

//code for when player enters Lava
void Player::_on_Lava_body_entered(_body) {
	var musicNode = $"Lava";
	musicNode.play();
	gas = 1000;
	hasDashed = false;
	isJumping = false;
	isFlying = false;
	$GasLabel.text = "Gas: " + str(gas);
	$CoinLabel.text = "Coins: " + str(coins);
	self.set_translation(spawnPoint);
}

void Player::handle_ledge_hang(){
	pass;
}

//test code for Player when entering a ledge
//When a player enters the collison shape we set isOnEdge to true
void Player::_on_Starting_Ledge_body_entered(body) {
	if body.get_name() == "Player" : isOnEdge = true;
}

//test code for Player when exits a ledge
//When a player exits the collison shape we set isOnEdge to false
void Player::_on_Starting_ledge_exited(body) {
	if body.get_name() == "Player" : isOnEdge = false;
}

void Player::_on_Gas_body_entered(_body) {
	var musicNode = $"Gas";
	musicNode.play();
	gas = 500;
	$GasLabel.text = "Gas: " + str(gas);
	pass; //Replace with function body.
}

	
