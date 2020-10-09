#include "Player.h"
extends KinematicBody

using namespace godot;

void Player::_register_methods() {
	register_method("_init", &Player::_init);
	register_method("_input", &Player::_ready);
	register_method("_physics_process", &Player::_physics_process);
	register_method("move_player", &Player::move_player);
	register_method("_on_Coin_body_entered", &Player::_on_Coin_body_entered);
	register_method("_on_Lava_body_entered", &Player::_on_Lava_body_entered);
	
	register_property("acceleration", &Player::acceleration, 5);
	register_property("speed", &Player::speed, 20);
	register_property("gravity", &Player::gravity, 0.98);

	register_property("velocity", &Player::velocity, Vector3);
	register_property("fall_velocity", &Player::fall_velocity, 0);
	register_property("isJumping", &Player::isJumping, false);
	register_property("isFlying", &Player::isFlying, false);

	register_property("spawnPoint", &Player::spawnPoint, Vector3(-80.077, 6.14, -22.868));
	register_property("coins", &Player::coin, 0);

	//get the camera
	onready register_property("cam", &Player::cam, get_node("Camera"));
	//sensitivity variable that controls rotation line 19
	register_property("sens", &Player::sens, 0.2);
}

void Player::_init() {

}

void Player::_input(event) {
	if (event is InputEventMouseMotion)
		//relative is the vector of how much mouse has moved
		var movement = event.relative;
		cam.rotation.x += -deg2rad(movement.y * sens);
		//make sure the camera rotats upward and downward within 90%
		cam.rotation.x = clamp(cam.rotation.x, deg2rad(-90), deg2rad(90));
		rotation.y += -deg2rad(movement.x * sens);
}
	

void Player::_physics_process(delta) {
	move_player(delta);
}
	


void Player::move_player(delta){
	var direction = Vector3(0, 0, 0);
	
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
		
	if (is_on_floor()) {
		fall_velocity = -0.01;
	} else {
		fall_velocity = fall_velocity - gravity;
	}
		
	if (Input.is_action_pressed("jump") && !isJumping && !Input.is_action_pressed("Fly")) {
		fall_velocity = 15;
		isJumping = true;
	}
		
	
	if (Input.is_action_pressed("Fly") && Input.is_action_pressed("jump")) {
		fall_velocity = 15;
		isFlying = true;
	}
		
	
	if (is_on_floor() && isJumping)
		isJumping = false;
	
	velocity.y = fall_velocity;
	velocity = move_and_slide(velocity, Vector3.UP);
}

void Player::_on_Coin_body_entered(_body) {
	coins += 1;
	print(coins);
}

void Player::_on_Lava_body_entered(_body) {
	self.set_translation(spawnPoint);
}
	
