extends Node2D

var planet



	
func add_shadow():
	if planet != null:
		if dist_sq_to_sun(planet) <= dist_sq_to_sun(self):
			$Sprite2D.set_self_modulate(Color("112222"))
		else:
			$Sprite2D.set_self_modulate(Color.WHITE)
		
func dist_sq_to_sun(object):
	var vector_to_sun = object.global_position - Globals.current_solar_system.sun.global_position
	var dist_sq = vector_to_sun.length_squared()
	return dist_sq
