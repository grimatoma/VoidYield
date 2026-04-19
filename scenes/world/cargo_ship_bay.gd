class_name CargoShipBay
extends Node2D
## Cargo Ship construction facility. Builds Freighters for trade routes.

const BULK_FREIGHTER_BUILD_TIME = 300.0  # 5 minutes in seconds
const BULK_FREIGHTER_COST = {
	"credits": 2000,
	"steel": 100,
	"alloy": 30,
}

var active_ships: Array = []
var construction_queue: Array = []
var is_building: bool = false

signal ship_constructed(cargo_class: String)
signal construction_started(cargo_class: String)


func construct_freighter(cargo_class: String) -> bool:
	if is_building:
		return false  # Can only build one at a time for now
	
	var cost = BULK_FREIGHTER_COST.duplicate()
	
	var build_job = {
		"cargo_class": cargo_class,
		"build_time": BULK_FREIGHTER_BUILD_TIME,
		"progress": 0.0,
	}
	
	construction_queue.append(build_job)
	is_building = true
	construction_started.emit(cargo_class)
	return true


func tick(delta: float) -> void:
	if construction_queue.is_empty():
		return
	
	var current_job = construction_queue[0]
	current_job["progress"] += delta
	
	if current_job["progress"] >= current_job["build_time"]:
		_complete_construction()


func _complete_construction() -> void:
	if construction_queue.is_empty():
		return
	
	var job = construction_queue.pop_front()
	var cargo_class = job["cargo_class"]
	
	# Create ship instance (simplified)
	var ship = {
		"cargo_class": cargo_class,
		"capacity": 1200 if cargo_class == "bulk" else 800,
	}
	active_ships.append(ship)
	
	ship_constructed.emit(cargo_class)
	is_building = false
