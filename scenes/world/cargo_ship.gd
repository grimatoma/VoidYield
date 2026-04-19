class_name CargoShip
extends RefCounted
## Cargo Ship with trip tracking and degradation system (M13).

const TRIP_BREAKDOWN_INTERVAL: int = 20
const BREAKDOWN_CHANCE: float = 0.05
const REPAIR_COST_ALLOY: int = 5

enum ShipType { BULK_FREIGHTER, LIQUID_TANKER, CONTAINER_SHIP, HEAVY_TRANSPORT }

var ship_type: ShipType = ShipType.BULK_FREIGHTER
var trips_completed: int = 0
var degradation_trips_counter: int = 0
var status: String = "ACTIVE"  # ACTIVE, LOADING, IN_TRANSIT, BREAKDOWN
var cargo_amount: int = 0
var ship_capacity: int = 1200
var repair_cost_alloy: int = REPAIR_COST_ALLOY


func _init(type: ShipType = ShipType.BULK_FREIGHTER) -> void:
	ship_type = type
	_set_capacity_by_type()


func _set_capacity_by_type() -> void:
	match ship_type:
		ShipType.BULK_FREIGHTER:
			ship_capacity = 1200
		ShipType.LIQUID_TANKER:
			ship_capacity = 800
		ShipType.CONTAINER_SHIP:
			ship_capacity = 600
		ShipType.HEAVY_TRANSPORT:
			ship_capacity = 3600


func complete_trip() -> void:
	trips_completed += 1
	degradation_trips_counter += 1

	if degradation_trips_counter >= TRIP_BREAKDOWN_INTERVAL:
		check_breakdown()
		degradation_trips_counter = 0


func check_breakdown() -> bool:
	if randf() < BREAKDOWN_CHANCE:
		status = "BREAKDOWN"
		return true
	return false


func repair() -> bool:
	if status == "BREAKDOWN":
		status = "ACTIVE"
		return true
	return false


func get_fill_percentage() -> float:
	if ship_capacity == 0:
		return 0.0
	return (float(cargo_amount) / ship_capacity) * 100.0


func is_ready_for_dispatch() -> bool:
	return get_fill_percentage() >= 80.0
