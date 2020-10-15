#ifndef PLAYER_H
#define PLAYER_H

#include <Godot.hpp>
#include <KinematicBody.hpp>
#include <KinematicCollision.hpp>
#include <cstdlib>

namespace godot {

	class Player : public KinematicBody {
		GODOT_CLASS(Player, KinematicBody);

	private:
		float acceleration;
		int speed;
		float gravity;

		Vector3 velocity;
		float walkableAngle;
		float fall_velocity;
		bool isJumping;
		bool isFlying;
		bool isOnEdge;
		bool canWalk;
		bool hasDashed;

		Vector3 spawnPoint;
		int coins;

		var cams;
		float sens;

	public:
		static void _register_methods();

		Player();
		~Player();

		void _init();
		void _input(event);
		void _process(float delta);
		void _physics_process(float delta);
		void move_player(float delta);
		void handle_gravity();
		void set_can_walk();
		void _on_Coin_body_entered(_body);
		void _on_Lava_body_entered(_body);
		void handle_ledge_hang();
		void _on_Starting_Ledge_body_entered(body);
		void _on_Starting_ledge_exited(body);
		void _on_Gas_body_entered(_body);
	};

}

#endif
#pragma once
