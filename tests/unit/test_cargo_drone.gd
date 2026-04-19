extends "res://tests/framework/test_case.gd"
## TDD unit tests for Cargo Drone (M13).

const CargoDroneScript = preload("res://scenes/vehicles/cargo_drone.gd")


func test_cargo_drone_has_correct_speed() -> void:
	var drone = CargoDroneScript.new()
	assert_eq(drone.speed, 35, "Cargo Drone speed should be 35 px/s")


func test_cargo_drone_has_correct_carry() -> void:
	var drone = CargoDroneScript.new()
	assert_eq(drone.carry_capacity, 20, "Cargo Drone should carry 20 units")


func test_cargo_drone_runs_freight_lanes() -> void:
	var drone = CargoDroneScript.new()
	assert_true(drone.has_method("execute_freight_lane"), "Cargo Drone should execute freight lanes")


func test_cargo_drone_no_fuel() -> void:
	var drone = CargoDroneScript.new()
	assert_eq(drone.fuel_type, "none", "Cargo Drone should require no fuel")


func test_cargo_drone_carries_cargo() -> void:
	var drone = CargoDroneScript.new()
	var cargo = 15

	assert_le(cargo, drone.carry_capacity, "Drone should carry up to 20 units")


func test_cargo_drone_drops_cargo_at_destination() -> void:
	var drone = CargoDroneScript.new()
	drone.cargo_amount = 20

	var dropped = drone.drop_cargo()
	assert_eq(dropped, 20, "Should drop all 20 cargo")
	assert_eq(drone.cargo_amount, 0, "Cargo should be empty after drop")


func test_cargo_drone_continuous_shuttle() -> void:
	var drone = CargoDroneScript.new()
	assert_true(drone.has_method("is_in_lane"), "Cargo Drone should track lane assignment")


func test_cargo_drone_at_capacity() -> void:
	var drone = CargoDroneScript.new()
	drone.cargo_amount = 20

	assert_true(drone.is_at_capacity(), "Drone at 20 cargo should be at capacity")


func test_cargo_drone_is_empty() -> void:
	var drone = CargoDroneScript.new()
	drone.cargo_amount = 0

	assert_true(drone.is_empty(), "Drone with 0 cargo should be empty")
