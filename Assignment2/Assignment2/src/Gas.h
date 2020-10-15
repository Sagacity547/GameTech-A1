#ifndef GAS_H
#define GAS_H

#include <Godot.hpp>
#include <Area.hpp>
#include <cstdlib>

namespace godot {

	class Gas : public Area {
		GODOT_CLASS(Gas, Area);

	public:
		static void _register_methods();

		Gas();
		~Gas();

		void _on_Gas_body_entered(_body);

	};
}
#pragma once
