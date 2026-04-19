extends "res://tests/framework/test_case.gd"
## TDD unit tests for HarvesterBase.
## Covers: fuel tank, hopper, extraction cycles, BER formula, refueling, collection.

var HarvesterBaseClass = preload("res://scenes/world/harvester_base.gd")

## Test double: OreQualityLot (simulate with a dict)
class OreQualityLot:
	var er: float = 800.0
	var fl: float = 0.0

## Test double: DepositNode with quality
class DepositNode:
	extends Node2D
	var quality: OreQualityLot
	var concentration: float = 100.0

	func _init() -> void:
		quality = OreQualityLot.new()
		concentration = 100.0

	func ber_output(base_ber: float, concentration: float, upgrade_mult: float) -> float:
		## Simulate the extraction formula from the spec:
		## Units = base_ber × (concentration/100) × (ER/1000) × upgrade_mult
		##       + (FL/1000 × base_ber × 0.5)
		var multiplier_chain = base_ber * (concentration / 100.0) * (quality.er / 1000.0) * upgrade_mult
		var fl_bonus = (quality.fl / 1000.0) * base_ber * 0.5
		return multiplier_chain + fl_bonus


func test_initial_fuel_full() -> void:
	var harvester = HarvesterBaseClass.new()
	harvester.fuel_capacity = 100.0
	harvester.fuel_level = 100.0
	assert_eq(harvester.fuel_level, 100.0, "initial fuel at capacity")


func test_initial_hopper_empty() -> void:
	var harvester = HarvesterBaseClass.new()
	harvester.hopper_capacity = 50
	harvester.hopper_ore = 0
	assert_eq(harvester.hopper_ore, 0, "initial hopper is empty")


func test_tick_does_not_cycle_before_time() -> void:
	var harvester = HarvesterBaseClass.new()
	harvester.cycle_time = 10.0
	harvester._cycle_timer = 0.0
	harvester.is_running = true

	harvester.tick(5.0)  # advance 5 seconds
	assert_eq(harvester._cycle_timer, 5.0, "timer advances")
	assert_lt(harvester._cycle_timer, harvester.cycle_time, "cycle not run before time")


func test_cycle_deducts_fuel() -> void:
	var harvester = HarvesterBaseClass.new()
	harvester.base_ber = 10.0
	harvester.cycle_time = 1.0
	harvester.fuel_capacity = 100.0
	harvester.fuel_level = 100.0
	harvester.fuel_per_cycle = 5.0
	harvester.hopper_capacity = 50
	harvester.hopper_ore = 0
	harvester.upgrade_multiplier = 1.0

	var deposit = DepositNode.new()
	deposit.quality.er = 800.0
	deposit.quality.fl = 0.0
	deposit.concentration = 100.0

	harvester.linked_deposit = deposit
	harvester.is_running = true
	harvester._cycle_timer = harvester.cycle_time

	var fuel_before = harvester.fuel_level
	harvester._run_cycle()
	assert_lt(harvester.fuel_level, fuel_before, "fuel deducted after cycle")
	assert_eq(harvester.fuel_level, fuel_before - harvester.fuel_per_cycle, "fuel deducted by fuel_per_cycle")


func test_cycle_adds_to_hopper() -> void:
	var harvester = HarvesterBaseClass.new()
	harvester.base_ber = 10.0
	harvester.cycle_time = 1.0
	harvester.fuel_capacity = 100.0
	harvester.fuel_level = 100.0
	harvester.fuel_per_cycle = 5.0
	harvester.hopper_capacity = 50
	harvester.hopper_ore = 0
	harvester.upgrade_multiplier = 1.0

	var deposit = DepositNode.new()
	deposit.quality.er = 800.0
	deposit.quality.fl = 0.0
	deposit.concentration = 100.0

	harvester.linked_deposit = deposit
	harvester.is_running = true
	harvester._cycle_timer = harvester.cycle_time

	harvester._run_cycle()
	assert_gt(harvester.hopper_ore, 0, "hopper filled after cycle")


func test_cycle_uses_ber_formula() -> void:
	var harvester = HarvesterBaseClass.new()
	harvester.base_ber = 10.0
	harvester.cycle_time = 1.0
	harvester.fuel_capacity = 100.0
	harvester.fuel_level = 100.0
	harvester.fuel_per_cycle = 5.0
	harvester.hopper_capacity = 50
	harvester.hopper_ore = 0
	harvester.upgrade_multiplier = 1.0

	var deposit = DepositNode.new()
	deposit.quality.er = 800.0  # ER = 800
	deposit.quality.fl = 0.0
	deposit.concentration = 100.0

	harvester.linked_deposit = deposit
	harvester.is_running = true
	harvester._cycle_timer = harvester.cycle_time

	# Expected: 10 × (100/100) × (800/1000) × 1.0 + 0 = 8
	harvester._run_cycle()
	assert_eq(harvester.hopper_ore, 8, "hopper has 8 ore (BER formula)")


func test_hopper_clamped_at_capacity() -> void:
	var harvester = HarvesterBaseClass.new()
	harvester.base_ber = 100.0  # Very high to fill quickly
	harvester.cycle_time = 1.0
	harvester.fuel_capacity = 1000.0
	harvester.fuel_level = 1000.0
	harvester.fuel_per_cycle = 5.0
	harvester.hopper_capacity = 50
	harvester.hopper_ore = 0
	harvester.upgrade_multiplier = 1.0

	var deposit = DepositNode.new()
	deposit.quality.er = 1000.0
	deposit.quality.fl = 0.0
	deposit.concentration = 100.0

	harvester.linked_deposit = deposit
	harvester.is_running = true
	harvester._cycle_timer = harvester.cycle_time

	harvester._run_cycle()  # Will produce way more than 50
	assert_lt(harvester.hopper_ore, harvester.hopper_capacity + 1, "hopper clamped at capacity")
	assert_eq(harvester.hopper_ore, harvester.hopper_capacity, "hopper at exact capacity")


func test_no_cycle_when_out_of_fuel() -> void:
	var harvester = HarvesterBaseClass.new()
	harvester.base_ber = 10.0
	harvester.cycle_time = 1.0
	harvester.fuel_capacity = 100.0
	harvester.fuel_level = 2.0  # Less than fuel_per_cycle
	harvester.fuel_per_cycle = 5.0
	harvester.hopper_capacity = 50
	harvester.hopper_ore = 0
	harvester.upgrade_multiplier = 1.0

	var deposit = DepositNode.new()
	harvester.linked_deposit = deposit
	harvester.is_running = true
	harvester._cycle_timer = harvester.cycle_time

	var hopper_before = harvester.hopper_ore
	harvester._run_cycle()
	assert_eq(harvester.hopper_ore, hopper_before, "no extraction when out of fuel")


func test_collect_hopper_empties_it() -> void:
	var harvester = HarvesterBaseClass.new()
	harvester.hopper_ore = 25

	var collected = harvester.collect_hopper()
	assert_eq(collected, 25, "collect_hopper returns hopper amount")
	assert_eq(harvester.hopper_ore, 0, "hopper emptied after collection")


func test_refuel_adds_fuel() -> void:
	var harvester = HarvesterBaseClass.new()
	harvester.fuel_capacity = 100.0
	harvester.fuel_level = 50.0

	harvester.refuel(30.0)
	assert_eq(harvester.fuel_level, 80.0, "fuel increased by refuel amount")


func test_refuel_clamped_at_capacity() -> void:
	var harvester = HarvesterBaseClass.new()
	harvester.fuel_capacity = 100.0
	harvester.fuel_level = 90.0

	harvester.refuel(50.0)  # Would exceed capacity
	assert_eq(harvester.fuel_level, harvester.fuel_capacity, "fuel clamped at capacity")


func test_is_full_returns_true_when_hopper_at_capacity() -> void:
	var harvester = HarvesterBaseClass.new()
	harvester.hopper_capacity = 50
	harvester.hopper_ore = 50

	assert_true(harvester.is_full(), "is_full true when hopper at capacity")


func test_is_full_returns_false_when_hopper_not_full() -> void:
	var harvester = HarvesterBaseClass.new()
	harvester.hopper_capacity = 50
	harvester.hopper_ore = 25

	assert_false(harvester.is_full(), "is_full false when hopper has space")


func test_is_out_of_fuel_returns_true_when_insufficient() -> void:
	var harvester = HarvesterBaseClass.new()
	harvester.fuel_level = 2.0
	harvester.fuel_per_cycle = 5.0

	assert_true(harvester.is_out_of_fuel(), "is_out_of_fuel true when insufficient")


func test_is_out_of_fuel_returns_false_when_sufficient() -> void:
	var harvester = HarvesterBaseClass.new()
	harvester.fuel_level = 10.0
	harvester.fuel_per_cycle = 5.0

	assert_false(harvester.is_out_of_fuel(), "is_out_of_fuel false when sufficient")


func test_cycle_completed_signal_emitted() -> void:
	var harvester = HarvesterBaseClass.new()
	harvester.base_ber = 10.0
	harvester.cycle_time = 1.0
	harvester.fuel_capacity = 100.0
	harvester.fuel_level = 100.0
	harvester.fuel_per_cycle = 5.0
	harvester.hopper_capacity = 50
	harvester.hopper_ore = 0
	harvester.upgrade_multiplier = 1.0

	var deposit = DepositNode.new()
	deposit.quality.er = 800.0
	deposit.quality.fl = 0.0
	deposit.concentration = 100.0

	harvester.linked_deposit = deposit
	harvester.is_running = true
	harvester._cycle_timer = harvester.cycle_time

	var signal_amounts = []
	harvester.cycle_completed.connect(func(amount):
		signal_amounts.append(amount)
	)

	harvester._run_cycle()
	assert_eq(signal_amounts.size(), 1, "cycle_completed signal emitted")
	assert_gt(signal_amounts[0], 0, "signal passes ore_added")


func test_hopper_collected_signal_emitted() -> void:
	var harvester = HarvesterBaseClass.new()
	harvester.hopper_ore = 25

	var signal_amounts = []
	harvester.hopper_collected.connect(func(amount):
		signal_amounts.append(amount)
	)

	harvester.collect_hopper()
	assert_eq(signal_amounts.size(), 1, "hopper_collected signal emitted")
	assert_eq(signal_amounts[0], 25, "signal passes correct amount")
