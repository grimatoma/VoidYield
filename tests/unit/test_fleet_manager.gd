extends "res://tests/framework/test_case.gd"
## TDD unit tests for FleetManager.

const FleetManagerScript = preload("res://scenes/drones/fleet_manager.gd")
const DroneBayScript = preload("res://scenes/drones/drone_bay.gd")
const ZoneManagerScript = preload("res://scenes/world/zone_manager.gd")
const RefineryDroneScript = preload("res://scenes/drones/refinery_drone.gd")

## Mock depot
class MockDepot:
	var stored: Dictionary = {}

	func deposit(ore_type: String, amount: int) -> int:
		stored[ore_type] = stored.get(ore_type, 0) + amount
		return amount


## Mock deposit
class MockDeposit:
	var ore_type: String = "common"
	var ore_available: int = 100

	func collect_ore(amount: int) -> Dictionary:
		var collected = mini(amount, ore_available)
		ore_available -= collected
		return {"ore_type": ore_type, "amount": collected}


var fleet_manager
var drone_bay
var zone_manager


func before_each() -> void:
	fleet_manager = FleetManagerScript.new()
	add_child(fleet_manager)

	drone_bay = DroneBayScript.new()
	add_child(drone_bay)

	zone_manager = ZoneManagerScript.new()
	add_child(zone_manager)


func after_each() -> void:
	if fleet_manager and fleet_manager.is_inside_tree():
		fleet_manager.queue_free()
	if drone_bay and drone_bay.is_inside_tree():
		drone_bay.queue_free()
	if zone_manager and zone_manager.is_inside_tree():
		zone_manager.queue_free()


func test_setup_links_components() -> void:
	fleet_manager.setup(drone_bay, zone_manager)

	assert_eq(fleet_manager.drone_bay, drone_bay)
	assert_eq(fleet_manager.zone_manager, zone_manager)


func test_auto_dispatch_assigns_idle_drones() -> void:
	var depot = MockDepot.new()
	var deposit = MockDeposit.new()
	var drone = RefineryDroneScript.new()
	add_child(drone)

	zone_manager.create_zone("zone_1", depot)
	zone_manager.add_deposit_to_zone("zone_1", deposit)
	drone_bay.register_drone(drone)

	fleet_manager.setup(drone_bay, zone_manager)
	fleet_manager.auto_dispatch()

	assert_false(drone.is_available(), "Drone should be assigned")


func test_auto_dispatch_returns_count() -> void:
	var depot = MockDepot.new()
	var deposit = MockDeposit.new()
	var drone1 = RefineryDroneScript.new()
	var drone2 = RefineryDroneScript.new()
	add_child(drone1)
	add_child(drone2)

	zone_manager.create_zone("zone_1", depot)
	zone_manager.add_deposit_to_zone("zone_1", deposit)
	drone_bay.register_drone(drone1)
	drone_bay.register_drone(drone2)

	fleet_manager.setup(drone_bay, zone_manager)
	var count = fleet_manager.auto_dispatch()

	assert_eq(count, 2, "Should dispatch 2 drones")


func test_utilization_zero_when_all_idle() -> void:
	var drone1 = RefineryDroneScript.new()
	var drone2 = RefineryDroneScript.new()
	add_child(drone1)
	add_child(drone2)

	drone_bay.register_drone(drone1)
	drone_bay.register_drone(drone2)

	fleet_manager.setup(drone_bay, zone_manager)

	assert_eq(fleet_manager.get_utilization(), 0.0, "Should be 0% utilized when all idle")


func test_utilization_one_when_all_busy() -> void:
	var depot = MockDepot.new()
	var deposit = MockDeposit.new()
	var drone1 = RefineryDroneScript.new()
	var drone2 = RefineryDroneScript.new()
	add_child(drone1)
	add_child(drone2)

	zone_manager.create_zone("zone_1", depot)
	zone_manager.add_deposit_to_zone("zone_1", deposit)
	drone_bay.register_drone(drone1)
	drone_bay.register_drone(drone2)

	fleet_manager.setup(drone_bay, zone_manager)
	fleet_manager.auto_dispatch()

	assert_eq(fleet_manager.get_utilization(), 1.0, "Should be 100% utilized when all busy")


func test_fleet_dispatched_signal_fires() -> void:
	var signal_received = []
	fleet_manager.fleet_dispatched.connect(func(count):
		signal_received.append(count)
	)

	var depot = MockDepot.new()
	var deposit = MockDeposit.new()
	var drone = RefineryDroneScript.new()
	add_child(drone)

	zone_manager.create_zone("zone_1", depot)
	zone_manager.add_deposit_to_zone("zone_1", deposit)
	drone_bay.register_drone(drone)

	fleet_manager.setup(drone_bay, zone_manager)
	fleet_manager.auto_dispatch()

	assert_eq(signal_received.size(), 1, "Signal should fire")
	assert_eq(signal_received[0], 1, "Should pass dispatch count")
