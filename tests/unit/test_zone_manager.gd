extends "res://tests/framework/test_case.gd"
## TDD unit tests for ZoneManager.

const ZoneManagerScript = preload("res://scenes/world/zone_manager.gd")
const RefineryDroneScript = preload("res://scenes/drones/refinery_drone.gd")

## Mock deposit
class MockDeposit:
	var ore_type: String = "common"
	var ore_available: int = 100

	func collect_ore(amount: int) -> Dictionary:
		var collected = mini(amount, ore_available)
		ore_available -= collected
		return {"ore_type": ore_type, "amount": collected}


## Mock depot
class MockDepot:
	var stored: Dictionary = {}

	func deposit(ore_type: String, amount: int) -> int:
		stored[ore_type] = stored.get(ore_type, 0) + amount
		return amount


var zone_manager


func before_each() -> void:
	zone_manager = ZoneManagerScript.new()
	add_child(zone_manager)


func after_each() -> void:
	if zone_manager and zone_manager.is_inside_tree():
		zone_manager.queue_free()


func test_create_zone_empty() -> void:
	var depot = MockDepot.new()

	zone_manager.create_zone("zone_1", depot)

	var zone = zone_manager.get_zone("zone_1")
	assert_false(zone.is_empty(), "Zone should exist")
	assert_eq(zone.deposits.size(), 0, "Should be empty initially")


func test_add_deposit_to_zone() -> void:
	var depot = MockDepot.new()
	var deposit = MockDeposit.new()

	zone_manager.create_zone("zone_1", depot)
	zone_manager.add_deposit_to_zone("zone_1", deposit)

	var zone = zone_manager.get_zone("zone_1")
	assert_eq(zone.deposits.size(), 1, "Should have one deposit")
	assert_eq(zone.deposits[0], deposit)


func test_assign_drone_circuit() -> void:
	var depot = MockDepot.new()
	var deposit = MockDeposit.new()
	var drone = RefineryDroneScript.new()
	add_child(drone)

	zone_manager.create_zone("zone_1", depot)
	zone_manager.add_deposit_to_zone("zone_1", deposit)
	zone_manager.assign_drone_to_zone("zone_1", drone)

	var zone = zone_manager.get_zone("zone_1")
	assert_eq(zone.drones.size(), 1, "Should have one drone")
	assert_eq(drone.assigned_deposit, deposit, "Drone should be assigned to deposit")
	assert_eq(drone.assigned_depot, depot, "Drone should be assigned to depot")


func test_zone_count_correct() -> void:
	var depot = MockDepot.new()

	zone_manager.create_zone("zone_1", depot)
	zone_manager.create_zone("zone_2", depot)
	zone_manager.create_zone("zone_3", depot)

	assert_eq(zone_manager.zone_count(), 3, "Should have 3 zones")


func test_drones_in_zone() -> void:
	var depot = MockDepot.new()
	var deposit = MockDeposit.new()
	var drone1 = RefineryDroneScript.new()
	var drone2 = RefineryDroneScript.new()
	add_child(drone1)
	add_child(drone2)

	zone_manager.create_zone("zone_1", depot)
	zone_manager.add_deposit_to_zone("zone_1", deposit)
	zone_manager.assign_drone_to_zone("zone_1", drone1)
	zone_manager.assign_drone_to_zone("zone_1", drone2)

	var drones = zone_manager.drones_in_zone("zone_1")
	assert_eq(drones.size(), 2, "Should have 2 drones in zone")
