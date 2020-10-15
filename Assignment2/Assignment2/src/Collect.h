#ifndef COLLECT_H
#define COLLECT_H

#include <Godot.hpp>
#include <Area.hpp>
#include <cstdlib>

namespace godot {

	class Collect : public Area {
		GODOT_CLASS(Collect, Area);

	public:
		static void _register_methods();

		Collect();
		~Collect();

		void _on_Coin_body_entered(_body);

	};
}

