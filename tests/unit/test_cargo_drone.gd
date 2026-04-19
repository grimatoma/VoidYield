class_name TestCargoDrone
extends TestCase

var drone: CargoDrone

func before_each() -> void:
	drone = CargoDrone.new()

func test_initial_carry_zero() -> void:
	assert_eq(drone.carrying, 0, "Drone should start with 0 cargo")

func test_pickup_fills_carrying() -> void:
	var picked_up = drone.pickup(10, "ore_common")
	assert_eq(picked_up, 10, "Should pickup requested amount")
	assert_eq(drone.carrying, 10, "Carrying should be updated")
	assert_eq(drone.carrying_type, "ore_common", "Should record ore type")

func test_pickup_capped_at_capacity() -> void:
	var picked_up = drone.pickup(25, "ore_rare")
	assert_eq(picked_up, 20, "Should cap at capacity of 20")
	assert_eq(drone.carrying, 20, "Carrying should be at capacity")

func test_deliver_empties_carrying() -> void:
	drone.pickup(15, "ore_voidstone")
	var delivered = drone.deliver()
	assert_eq(delivered.amount, 15, "Should deliver all carrying")
	assert_eq(drone.carrying, 0, "Carrying should be reset to 0")

func test_deliver_returns_correct_amount() -> void:
	drone.pickup(8, "ore_aethite")
	var delivered = drone.deliver()
	assert_eq(delivered.type, "ore_aethite", "Should return correct ore type")
	assert_eq(delivered.amount, 8, "Should return correct amount")
