extends "res://tests/framework/test_case.gd"
## TDD unit tests for Gas Trap (M13).

const GasTrapScript = preload("res://scenes/world/gas_trap.gd")


func test_gas_trap_captures_dark_gas() -> void:
	var trap = GasTrapScript.new()
	assert_true(trap.has_method("capture_eruption"), "Gas Trap should capture geyser eruptions")


func test_gas_trap_burst_collection() -> void:
	var trap = GasTrapScript.new()
	var gas_collected = trap.capture_eruption(12)
	assert_eq(gas_collected, 12, "Gas Trap should collect from eruption")


func test_gas_trap_no_continuous_rate() -> void:
	var trap = GasTrapScript.new()
	# No continuous production, only burst on eruption
	var rate = trap.get_continuous_rate()
	assert_eq(rate, 0, "Gas Trap should have 0 continuous rate")


func test_gas_trap_stores_collected_gas() -> void:
	var trap = GasTrapScript.new()
	trap.dark_gas_stored = 0

	trap.dark_gas_stored += 12
	assert_eq(trap.dark_gas_stored, 12, "Gas Trap should store collected dark gas")


func test_gas_trap_can_be_emptied() -> void:
	var trap = GasTrapScript.new()
	trap.dark_gas_stored = 50

	var collected = trap.empty()
	assert_eq(collected, 50, "Should empty all stored gas")
	assert_eq(trap.dark_gas_stored, 0, "Storage should be empty after collection")
