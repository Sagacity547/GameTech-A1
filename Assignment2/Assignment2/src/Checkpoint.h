#ifndef CHECKPOINT_H
#define CHECKPOINT_H

#include <Godot.hpp>
#include <Area.hpp>
#include <cstdlib>

namespace godot {

	class Checkpoint : public Area {
		GODOT_CLASS(Checkpoint, Area);

	public:
		static void _register_methods();

		Checkpoint();
		~Checkpoint();

		void _on_Start_Check_body_entered(body);

	private:
		Vector3 spawnPoint;

	};
}
#pragma once
