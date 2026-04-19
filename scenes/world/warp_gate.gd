class_name WarpGate
extends Node2D
## Warp Gate — instant interplanetary travel hub (M14, tech 3.P).

const requires_tech_3p: bool = true
const build_cost_cr: int = 20000
const build_cost_void_cores: int = 50
const build_cost_alloy: int = 100
const build_time: float = 300.0

var status: String = "BUILDING"  # BUILDING, ACTIVE
var build_progress: float = 0.0


func _ready() -> void:
	pass


func tick(delta: float) -> void:
	if status == "BUILDING":
		build_progress += delta
		if build_progress >= build_time:
			status = "ACTIVE"


func get_fuel_cost() -> int:
	return 0  # Warp travel costs no fuel


func travel_between_planets(source: String, destination: String) -> bool:
	if status != "ACTIVE":
		return false

	# Instant travel from source to destination
	return true


func is_active() -> bool:
	return status == "ACTIVE"


func get_warp_cost() -> Dictionary:
	return {
		"fuel": 0,
		"credits": 0,
		"time": 0.1  # Nearly instantaneous
	}
