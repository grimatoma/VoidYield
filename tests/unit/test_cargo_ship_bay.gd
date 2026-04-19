extends "res://tests/framework/test_case.gd"
## Unit tests for Cargo Ship Bay.

const CargoShipBayScript = preload("res://scenes/world/cargo_ship_bay.gd")


func test_cargo_ship_bay_initializes() -> void:
	var bay = CargoShipBayScript.new()
	assert_eq(bay.active_ships.size(), 0, "Should start with no ships")


func test_cargo_ship_bay_can_construct_bulk_freighter() -> void:
	var bay = CargoShipBayScript.new()
	var success = bay.construct_freighter("bulk")
	assert_true(success, "Should start bulk freighter construction")


func test_cargo_ship_bay_tracks_building_progress() -> void:
	var bay = CargoShipBayScript.new()
	bay.construct_freighter("bulk")
	assert_gt(bay.construction_queue.size(), 0, "Should queue construction job")


func test_cargo_ship_bay_construction_takes_time() -> void:
	var bay = CargoShipBayScript.new()
	bay.construct_freighter("bulk")
	var job = bay.construction_queue[0]
	assert_eq(job["build_time"], 300.0, "Bulk Freighter should take 300 s (5 min)")
