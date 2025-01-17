extends Node

var current_level
var current_hud
var current_solar_system
var current_player

enum goals { trees, planets, atmospheres, civilizations, aliens }

enum control_schemes { WASD, MOUSE }
var control_scheme = control_schemes.WASD
