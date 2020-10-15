#include "Checkpoint.h"

using namespace godot;

void Checkpoint::_register_methods() {
	register_method("_on_Start_Check_body_entered", &Checkpoint::_on_Start_Check_body_entered);

	register_property("spawnPoint", &Checkpoint::spawnPoint, Vector3(-75.032, 5.752, -15.685));
}

void Checkpoint::_on_Start_Check_body_entered(body) {
	if (body.name == "Player")
		body.spawnPoint = position;
}
