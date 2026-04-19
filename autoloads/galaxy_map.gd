class_name GalaxyMap
extends RefCounted
## Manages available planets and current location.

var planets: Dictionary = {
	"a1": {
		"name": "Planet A1",
		"unlocked": true,
		"position": Vector2(200, 300),
	},
	"planet_b": {
		"name": "Planet B",
		"unlocked": false,
		"position": Vector2(500, 300),
	},
	"a2": {
		"name": "A2 Transit Asteroid",
		"unlocked": false,
		"position": Vector2(350, 150),
	},
	"planet_c": {
		"name": "Planet C",
		"unlocked": false,
		"position": Vector2(650, 400),
	},
	"a3": {
		"name": "A3 Nexus",
		"unlocked": false,
		"position": Vector2(400, 550),
	},
}

var current_planet: String = "a1"

signal planet_unlocked(planet_id: String)
signal planet_traveled(from_planet: String, to_planet: String)


func unlock_planet(planet_id: String) -> void:
	if planet_id in planets:
		planets[planet_id]["unlocked"] = true
		planet_unlocked.emit(planet_id)


func travel_to(planet_id: String) -> bool:
	if not planet_id in planets:
		return false
	
	if not planets[planet_id]["unlocked"]:
		return false
	
	var from_planet = current_planet
	current_planet = planet_id
	planet_traveled.emit(from_planet, planet_id)
	return true


func is_planet_unlocked(planet_id: String) -> bool:
	if not planet_id in planets:
		return false
	return planets[planet_id]["unlocked"]
