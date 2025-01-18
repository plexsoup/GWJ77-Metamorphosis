extends Node

var current_level
var current_hud
var current_solar_system
var current_player

enum goals { move, trees, planets, atmospheres, civilizations, aliens }

enum control_schemes { WASD, MOUSE }
var control_scheme = control_schemes.WASD

func teleport_rigid_body(object, new_location):
	object.linear_velocity = Vector2.ZERO
	object.angular_velocity = 0.0
	object.sleeping = true
	#object.transform.origin = new_location
	
	var new_transform = Transform2D(object.rotation, new_location)
	PhysicsServer2D.body_set_state(
		object.get_rid(),
		PhysicsServer2D.BODY_STATE_TRANSFORM,
		new_transform
	)
	object.set_deferred("sleeping", false)
	
