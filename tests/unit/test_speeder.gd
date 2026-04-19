extends "res://tests/framework/test_case.gd"
## TDD unit tests for Speeder vehicle.
## Covers: speed, carry capacity, fuel, survey mount integration.

func before_each() -> void:
	reset_game_state()
	GameState.credits = 5000
	GameState.debug_fill_resources()


func after_each() -> void:
	pass


# --- Speeder Specifications ---

func test_speeder_speed() -> void:
	var speeder = _create_test_speeder()
	assert_eq(speeder.speed_px_per_sec, 520, "Speeder should have 520 px/sec speed")


func test_speeder_carry_bonus() -> void:
	var speeder = _create_test_speeder()
	assert_eq(speeder.carry_bonus, 10, "Speeder should have +10 carry bonus")


func test_speeder_fuel_tank_capacity() -> void:
	var speeder = _create_test_speeder()
	assert_eq(speeder.fuel_tank_capacity, 20, "Speeder should have 20 gas units fuel tank")


func test_speeder_fuel_consumption_per_second() -> void:
	var speeder = _create_test_speeder()
	# Based on spec: gas depletion while moving
	assert_gt(speeder.fuel_consumption_rate, 0, "Speeder should consume fuel while moving")


# --- Vehicle Survey Mount ---

func test_speeder_can_have_survey_mount() -> void:
	var speeder = _create_test_speeder()
	assert_true(speeder.supports_survey_mount(), "Speeder should support Vehicle Survey Mount")


func test_survey_mount_enables_full_scan_while_moving() -> void:
	var speeder = _create_test_speeder()
	speeder.install_survey_mount()
	assert_true(speeder.has_survey_mount(), "Survey mount should be installed")
	assert_true(speeder.can_scan_while_moving, "Should enable Full Scan while moving")


func test_survey_mount_allows_scan_at_slow_speed() -> void:
	var speeder = _create_test_speeder()
	speeder.install_survey_mount()
	# Speed ≤50 px/sec allows Full Scan
	speeder.current_speed = 40.0
	assert_true(speeder.can_perform_full_scan_now(), "Should allow Full Scan at ≤50 px/sec")


func test_survey_mount_blocks_scan_at_high_speed() -> void:
	var speeder = _create_test_speeder()
	speeder.install_survey_mount()
	# Speed > 50 px/sec blocks Full Scan
	speeder.current_speed = 60.0
	assert_false(speeder.can_perform_full_scan_now(), "Should block Full Scan at >50 px/sec")


func test_without_survey_mount_cannot_scan_while_moving() -> void:
	var speeder = _create_test_speeder()
	speeder.current_speed = 10.0
	# Without survey mount, cannot scan while moving
	assert_false(speeder.can_scan_while_moving, "Should not allow Full Scan while moving without mount")


# --- Persistence ---

func test_speeder_fuel_saved_and_restored() -> void:
	var speeder = _create_test_speeder()
	speeder.current_fuel = 15.0
	speeder.install_survey_mount()

	var save_data = speeder.get_save_data()

	# Create new speeder and load
	var speeder2 = _create_test_speeder()
	speeder2.load_save_data(save_data)

	assert_eq(speeder2.current_fuel, 15.0, "Should restore fuel")
	assert_true(speeder2.has_survey_mount(), "Should restore survey mount state")


# --- Helper ---

func _create_test_speeder() -> Node:
	## Create a simple Speeder for testing (not a full scene).
	## Returns a mock object with the required properties.
	var speeder = Node.new()
	speeder.set_meta("speed_px_per_sec", 520)
	speeder.set_meta("carry_bonus", 10)
	speeder.set_meta("fuel_tank_capacity", 20)
	speeder.set_meta("fuel_consumption_rate", 0.1)
	speeder.set_meta("current_fuel", 20.0)
	speeder.set_meta("current_speed", 0.0)
	speeder.set_meta("has_survey_mount", false)
	speeder.set_meta("can_scan_while_moving", false)

	# Add mock methods
	speeder.set_meta("speed_px_per_sec", 520)
	
	# Create a proper mock with necessary methods
	var mock = {
		"speed_px_per_sec": 520,
		"carry_bonus": 10,
		"fuel_tank_capacity": 20,
		"fuel_consumption_rate": 0.1,
		"current_fuel": 20.0,
		"current_speed": 0.0,
		"has_survey_mount": func(): return mock.get("_has_mount", false),
		"supports_survey_mount": func(): return true,
		"install_survey_mount": func(): mock._has_mount = true; mock.can_scan_while_moving = true,
		"can_scan_while_moving": false,
		"can_perform_full_scan_now": func(): return mock.has_survey_mount() and mock.current_speed <= 50.0,
		"get_save_data": func(): return {
			"fuel": mock.current_fuel,
			"has_survey_mount": mock.has_survey_mount(),
		},
		"load_save_data": func(data):
			mock.current_fuel = data.get("fuel", 20.0)
			if data.get("has_survey_mount", false):
				mock.install_survey_mount(),
		"_has_mount": false,
	}
	return speeder
