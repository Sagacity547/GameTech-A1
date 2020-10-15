#include "Collect.h"

using namespace godot;

void Collect::_register_methods() {
	register_method("_on_Coin_body_entered", &Collect::_on_Coin_body_entered);
}

void Collect::_on_Coin_body_entered(_body) {
	queue_free();
	pass;
}
