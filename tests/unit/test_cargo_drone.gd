extends "res://tests/framework/test_case.gd"

const CargoDroneScript = preload("res://scenes/drones/cargo_drone.gd")

var drone


func before_each() -> void:
	drone = CargoDroneScript.new()
	add_child(drone)


func after_each() -> void:
	if drone and drone.is_inside_tree():
		drone.queue_free()


func test_initial_zero() -> void:
	assert_eq(drone.carrying, 0, "Should start with zero cargo")


func test_pickup_fills() -> void:
	var picked_up = drone.pickup(10, "iron")

	assert_eq(drone.carrying, 10, "Should store picked up amount")
	assert_eq(picked_up, 10, "Should return actual picked up amount")


func test_pickup_capped() -> void:
	var picked_up = drone.pickup(100, "iron")

	assert_eq(drone.carrying, CargoDroneScript.CARRY_CAPACITY, "Should cap at capacity")
	assert_eq(picked_up, CargoDroneScript.CARRY_CAPACITY, "Should return capped amount")


func test_pickup_returns_actual() -> void:
	drone.pickup(10, "iron")
	var second_pickup = drone.pickup(20, "iron")

	assert_eq(second_pickup, 10, "Should return amount actually picked up")
	assert_eq(drone.carrying, CargoDroneScript.CARRY_CAPACITY, "Should be at capacity")


func test_deliver_correct_amount() -> void:
	drone.pickup(15, "iron")
	var delivered = drone.deliver()

	assert_eq(delivered.amount, 15, "Should deliver correct amount")
	assert_eq(delivered.ore_type, "iron", "Should preserve ore type")


func test_deliver_resets_to_zero() -> void:
	drone.pickup(10, "iron")
	drone.deliver()

	assert_eq(drone.carrying, 0, "Should reset to zero after delivery")
