class_name StrandingManager
extends RefCounted
## Manages stranding status on Planet B. Player arrives with 20 RF, needs 100 to escape.

const ARRIVAL_FUEL = 20.0
const ESCAPE_FUEL_REQUIRED = 100.0

var rocket_fuel_current: float = 0.0
var is_on_planet_b: bool = false


func is_stranded() -> bool:
	if not is_on_planet_b:
		return false
	return rocket_fuel_current < ESCAPE_FUEL_REQUIRED


func arrive_on_planet_b() -> void:
	is_on_planet_b = true
	rocket_fuel_current = ARRIVAL_FUEL


func add_fuel(amount: float) -> void:
	rocket_fuel_current += amount


func can_launch_to_a1() -> bool:
	return rocket_fuel_current >= ESCAPE_FUEL_REQUIRED


func launch_to_a1() -> void:
	if can_launch_to_a1():
		is_on_planet_b = false
		rocket_fuel_current -= ESCAPE_FUEL_REQUIRED
