extends "res://tests/framework/test_case.gd"
## TDD unit tests for RefineryDrone autonomous operation.

const RefineryDroneScript = preload("res://scenes/drones/refinery_drone.gd")

## Mock DepositNode for testing
class MockDeposit:
	var ore_type: String = "common"
	var ore_available: int = 100

	func collect_ore(amount: int) -> Dictionary:
		var collected = mini(amount, ore_available)
		ore_available -= collected
		return {"ore_type": ore_type, "amount": collected}


## Mock StorageDepot for testing
class MockDepot:
	var stored: Dictionary = {}

	func deposit(ore_type: String, amount: int) -> int:
		stored[ore_type] = stored.get(ore_type, 0) + amount
		return amount


var drone


func before_each() -> void:
	drone = RefineryDroneScript.new()
	add_child(drone)


func after_each() -> void:
	if drone and drone.is_inside_tree():
		drone.queue_free()


func test_initial_state_idle() -> void:
	assert_eq(drone.state, RefineryDroneScript.State.IDLE, "Should start idle")


func test_initial_fuel_full() -> void:
	assert_eq(drone.fuel_level, RefineryDroneScript.FUEL_CAPACITY, "Should start with full fuel")


func test_assign_circuit_sets_targets() -> void:
	var deposit = MockDeposit.new()
	var depot = MockDepot.new()

	drone.assign_circuit(deposit, depot)

	assert_eq(drone.assigned_deposit, deposit, "Should set deposit target")
	assert_eq(drone.assigned_depot, depot, "Should set depot target")


func test_assign_circuit_transitions_state() -> void:
	var deposit = MockDeposit.new()
	var depot = MockDepot.new()

	drone.assign_circuit(deposit, depot)

	assert_eq(drone.state, RefineryDroneScript.State.MOVING_TO_DEPOSIT, "Should transition to MOVING_TO_DEPOSIT")


func test_tick_in_moving_transitions_to_harvesting() -> void:
	var deposit = MockDeposit.new()
	var depot = MockDepot.new()

	drone.assign_circuit(deposit, depot)
	drone.tick(0.016)

	assert_eq(drone.state, RefineryDroneScript.State.HARVESTING, "Should transition to HARVESTING")


func test_harvest_collects_from_deposit() -> void:
	var deposit = MockDeposit.new()
	var depot = MockDepot.new()

	drone.assign_circuit(deposit, depot)
	drone.tick(0.016)  # Move to deposit
	drone.tick(0.016)  # Harvest

	assert_gt(drone.carrying, 0, "Should collect ore from deposit")


func test_harvest_fills_carrying() -> void:
	var deposit = MockDeposit.new()
	var depot = MockDepot.new()

	drone.assign_circuit(deposit, depot)
	drone.tick(0.016)  # Move
	drone.tick(0.016)  # Harvest

	assert_eq(drone.carrying, RefineryDroneScript.CARRY_CAPACITY, "Should fill to capacity")
	assert_eq(drone.cargo_type, "common", "Should set cargo type")


func test_deliver_deposits_to_depot() -> void:
	var deposit = MockDeposit.new()
	var depot = MockDepot.new()

	drone.assign_circuit(deposit, depot)
	drone.tick(0.016)  # Move to deposit
	drone.tick(0.016)  # Harvest
	drone.tick(0.016)  # Move to depot
	drone.tick(0.016)  # Deliver

	assert_gt(depot.stored.get("common", 0), 0, "Should deposit ore to depot")


func test_deliver_resets_carrying() -> void:
	var deposit = MockDeposit.new()
	var depot = MockDepot.new()

	drone.assign_circuit(deposit, depot)
	drone.tick(0.016)  # Move to deposit
	drone.tick(0.016)  # Harvest
	drone.tick(0.016)  # Move to depot
	drone.tick(0.016)  # Deliver

	assert_eq(drone.carrying, 0, "Should reset carrying after delivery")


func test_deliver_deducts_fuel() -> void:
	var deposit = MockDeposit.new()
	var depot = MockDepot.new()

	var fuel_before = drone.fuel_level
	drone.assign_circuit(deposit, depot)
	drone.tick(0.016)  # Move
	drone.tick(0.016)  # Harvest
	drone.tick(0.016)  # Move
	drone.tick(0.016)  # Deliver

	assert_lt(drone.fuel_level, fuel_before, "Should deduct fuel after delivery")
	assert_eq(drone.fuel_level, fuel_before - RefineryDroneScript.FUEL_PER_TRIP, "Should deduct correct amount")


func test_fuel_low_signal_when_low_fuel() -> void:
	var signal_received = []
	drone.fuel_low.connect(func(fuel):
		signal_received.append(fuel)
	)

	var deposit = MockDeposit.new()
	var depot = MockDepot.new()

	drone.fuel_level = 25.0  # Below threshold of 30
	drone.assign_circuit(deposit, depot)
	drone.tick(0.016)
	drone.tick(0.016)  # This should trigger fuel_low

	assert_gt(signal_received.size(), 0, "Signal should fire")


func test_circuit_completed_signal_on_deliver() -> void:
	var signal_received = []
	drone.circuit_completed.connect(func(ore_type, amount):
		signal_received.append({"type": ore_type, "amount": amount})
	)

	var deposit = MockDeposit.new()
	var depot = MockDepot.new()

	drone.assign_circuit(deposit, depot)
	drone.tick(0.016)  # Move
	drone.tick(0.016)  # Harvest
	drone.tick(0.016)  # Move
	drone.tick(0.016)  # Deliver

	assert_gt(signal_received.size(), 0, "Signal should fire on delivery")


func test_refuel_restores_fuel() -> void:
	drone.fuel_level = 30.0

	drone.refuel(200.0)  # More than capacity — should clamp

	assert_eq(drone.fuel_level, RefineryDroneScript.FUEL_CAPACITY, "Should clamp at capacity")


func test_is_available_when_idle() -> void:
	assert_true(drone.is_available(), "Should be available when idle")


func test_is_not_available_when_busy() -> void:
	var deposit = MockDeposit.new()
	var depot = MockDepot.new()

	drone.assign_circuit(deposit, depot)

	assert_false(drone.is_available(), "Should not be available when assigned")
