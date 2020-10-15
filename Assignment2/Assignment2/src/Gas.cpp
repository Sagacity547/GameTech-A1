#include "Gas.h"

using namespace godot;

void Gas::_register_methods() {
	register_method("_on_Gas_body_entered", &Gas::_on_Gas_body_entered);
}

void Gas::_on_Gas_body_entered(_body) {
	queue_free();
	pass;
}
