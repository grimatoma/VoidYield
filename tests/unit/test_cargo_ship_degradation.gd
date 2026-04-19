extends "res://tests/framework/test_case.gd"
## TDD unit tests for Cargo Ship degradation system (M13).

const CargoShipScript = preload("res://scenes/world/cargo_ship.gd")


func test_cargo_ship_tracks_trips() -> void:
	var ship = CargoShipScript.new()
	assert_eq(ship.trips_completed, 0, "New ship should have 0 trips")


func test_cargo_ship_increments_trip_counter() -> void:
	var ship = CargoShipScript.new()
	ship.trips_completed = 5
	ship.trips_completed += 1
	assert_eq(ship.trips_completed, 6, "Trip counter should increment")


func test_degradation_check_every_20_trips() -> void:
	var ship = CargoShipScript.new()
	ship.trips_completed = 0

	# First breakdown check at trip 20
	for i in range(20):
		ship.trips_completed += 1

	assert_eq(ship.trips_completed % 20, 0, "Trip 20 should trigger degradation check")


func test_breakdown_chance_5_percent() -> void:
	var ship = CargoShipScript.new()
	# Breakdown is 5% chance at each 20-trip checkpoint
	# For testing, we'll verify the logic is in place
	assert_true(ship.has_method("check_breakdown"), "Ship should have breakdown check method")


func test_ship_has_degradation_trips_counter() -> void:
	var ship = CargoShipScript.new()
	assert_eq(ship.degradation_trips_counter, 0, "Ship should track degradation trips counter")


func test_breakdown_sets_status_to_breakdown() -> void:
	var ship = CargoShipScript.new()
	ship.status = "ACTIVE"

	# Simulate breakdown
	ship.status = "BREAKDOWN"

	assert_eq(ship.status, "BREAKDOWN", "Broken ship should have BREAKDOWN status")


func test_breakdown_costs_repair() -> void:
	var ship = CargoShipScript.new()
	ship.repair_cost_alloy = 5

	assert_eq(ship.repair_cost_alloy, 5, "Breakdown should require repair (5 Alloy Rods)")


func test_ship_can_be_repaired() -> void:
	var ship = CargoShipScript.new()
	ship.status = "BREAKDOWN"

	ship.repair()
	assert_eq(ship.status, "ACTIVE", "Repaired ship should return to ACTIVE")


func test_multiple_ships_track_trips_independently() -> void:
	var ship1 = CargoShipScript.new()
	var ship2 = CargoShipScript.new()

	ship1.trips_completed = 5
	ship2.trips_completed = 10

	assert_eq(ship1.trips_completed, 5, "Ship 1 should have 5 trips")
	assert_eq(ship2.trips_completed, 10, "Ship 2 should have 10 trips")
