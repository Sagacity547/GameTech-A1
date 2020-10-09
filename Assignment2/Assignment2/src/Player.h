#ifndef PLAYER_H
#define PLAYER_H

#include <Godot.hpp>
#include <KinematicBody.hpp>
#include <KinematicCollision.hpp>
#include <cstdlib>

namespace godot {

	class Player : public KinematicBody {
		GODOT_CLASS(Player, KinematicBody);
		float acceleration;
		int speed;
		float gravity;

		Vector3 velocity;
		bool isJumping;
		bool isFlying;
		Vector3 spawnPoint;
		int coins;

		var cams;
		float sens;

	public:
		static void _register_methods();
		void _init();
		void _input(event);
		void _physics_process(float delta);
		void move_player(delta);
		void _on_Coin_body_entered(_body);
		void _on_Lava_body_entered(_body);
	};

}

#endif
#pragma once
