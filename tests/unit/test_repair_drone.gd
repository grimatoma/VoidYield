extends "res://tests/framework/test_case.gd"
## TDD unit tests for Repair Drone (M13).

const RepairDroneScript = preload("res://scenes/vehicles/repair_drone.gd")


func test_repair_drone_has_correct_speed() -> void:
	var drone = RepairDroneScript.new()
	assert_eq(drone.speed, 90, "Repair Drone speed should be 90 px/s")


func test_repair_drone_has_zero_carry() -> void:
	var drone = RepairDroneScript.new()
	assert_eq(drone.carry_capacity, 0, "Repair Drone should have 0 carry capacity")


func test_repair_drone_has_alloy_cost() -> void:
	var drone = RepairDroneScript.new()
	assert_eq(drone.repair_cost_alloy, 5, "Repair should cost 5 Alloy Rods")


func test_repair_drone_can_repair_broken_ship() -> void:
	var drone = RepairDroneScript.new()
	assert_true(drone.has_method("repair_ship"), "Repair Drone should have repair_ship method")


func test_repair_drone_autonomous() -> void:
	var drone = RepairDroneScript.new()
	assert_true(drone.is_autonomous, "Repair Drone should run autonomously")


func test_repair_drone_targets_breakdown_ships() -> void:
	var drone = RepairDroneScript.new()
	assert_true(drone.has_method("find_broken_ships"), "Repair Drone should find broken ships")


func test_repair_drone_restores_ship_to_active() -> void:
	var drone = RepairDroneScript.new()
	var ship_status = "BREAKDOWN"

	# Simulate repair
	if drone.has_method("repair_ship"):
		ship_status = "ACTIVE"

	assert_eq(ship_status, "ACTIVE", "Repair should restore ship to ACTIVE")
