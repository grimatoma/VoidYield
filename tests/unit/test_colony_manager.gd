extends "res://tests/framework/test_case.gd"
## TDD unit tests for ColonyManager.
## Covers: initial state, growth mechanics, needs tracking, morale calculation,
##         and serialization.


# --- Initial State Tests ---

func test_starts_with_4_pioneers() -> void:
	var cm = ColonyManager.new()
	assert_eq(cm.pioneer_count, 4, "should start with 4 pioneers")


func test_initial_housing_capacity() -> void:
	var cm = ColonyManager.new()
	assert_eq(cm.housing_capacity, 8, "should start with 8 housing capacity (1 basic module)")


func test_initial_needs_unmet() -> void:
	var cm = ColonyManager.new()
	assert_eq(cm.needs_met["water"], false, "water should start unmet")
	assert_eq(cm.needs_met["food"], false, "food should start unmet")
	assert_eq(cm.needs_met["power"], false, "power should start unmet")
	assert_eq(cm.needs_met["luxury_goods"], false, "luxury_goods should start unmet")


func test_initial_morale() -> void:
	var cm = ColonyManager.new()
	assert_eq(cm.morale, 0.0, "morale should start at 0.0 (all basic needs unmet)")


# --- Growth Tests ---

func test_growth_triggers_after_90s_with_needs_met() -> void:
	var cm = ColonyManager.new()
	cm.set_need("water", true)
	cm.set_need("food", true)
	cm.set_need("power", true)

	var signal_received = false
	var new_count = -1
	cm.pioneer_count_changed.connect(func(c: int) -> void:
		signal_received = true
		new_count = c
	)

	cm.tick(45.0)
	assert_eq(cm.pioneer_count, 4, "no growth after 45s")
	assert_false(signal_received, "signal should not fire before 90s")

	cm.tick(45.0)
	assert_eq(cm.pioneer_count, 5, "should grow to 5 pioneers after 90s total")
	assert_true(signal_received, "pioneer_count_changed signal should fire")
	assert_eq(new_count, 5, "signal should pass new count (5)")


func test_growth_timer_resets_after_trigger() -> void:
	var cm = ColonyManager.new()
	cm.set_need("water", true)
	cm.set_need("food", true)
	cm.set_need("power", true)

	cm.tick(90.0)
	assert_eq(cm.pioneer_count, 5, "first growth triggers at 90s")

	# Another 90s should trigger second growth
	cm.tick(90.0)
	assert_eq(cm.pioneer_count, 6, "second growth triggers after another 90s")


func test_no_growth_when_water_unmet() -> void:
	var cm = ColonyManager.new()
	cm.set_need("food", true)
	cm.set_need("power", true)
	# water remains unmet

	cm.tick(90.0)
	assert_eq(cm.pioneer_count, 4, "no growth when water unmet")


func test_no_growth_when_food_unmet() -> void:
	var cm = ColonyManager.new()
	cm.set_need("water", true)
	cm.set_need("power", true)
	# food remains unmet

	cm.tick(90.0)
	assert_eq(cm.pioneer_count, 4, "no growth when food unmet")


func test_no_growth_when_power_unmet() -> void:
	var cm = ColonyManager.new()
	cm.set_need("water", true)
	cm.set_need("food", true)
	# power remains unmet

	cm.tick(90.0)
	assert_eq(cm.pioneer_count, 4, "no growth when power unmet")


func test_no_growth_at_housing_capacity() -> void:
	var cm = ColonyManager.new()
	cm.set_need("water", true)
	cm.set_need("food", true)
	cm.set_need("power", true)

	# Fill housing to capacity
	cm.pioneer_count = 8

	cm.tick(90.0)
	assert_eq(cm.pioneer_count, 8, "no growth when at capacity")


# --- Needs Tests ---

func test_set_need_updates_state() -> void:
	var cm = ColonyManager.new()
	assert_eq(cm.needs_met["water"], false, "water starts unmet")

	cm.set_need("water", true)
	assert_eq(cm.needs_met["water"], true, "water should be met after set_need")


func test_needs_changed_signal_fires() -> void:
	var cm = ColonyManager.new()
	var signal_received = false
	var need_name = ""
	var need_state = false

	cm.needs_changed.connect(func(n: String, s: bool) -> void:
		signal_received = true
		need_name = n
		need_state = s
	)

	cm.set_need("water", true)
	assert_true(signal_received, "needs_changed signal should fire")
	assert_eq(need_name, "water", "signal should pass need name")
	assert_eq(need_state, true, "signal should pass true for met")


# --- Morale Tests ---

func test_morale_zero_when_all_basic_needs_unmet() -> void:
	var cm = ColonyManager.new()
	# All needs start unmet
	assert_eq(cm.morale, 0.0, "morale is 0.0 when all basic needs unmet")


func test_morale_full_when_all_basic_needs_met() -> void:
	var cm = ColonyManager.new()
	cm.set_need("water", true)
	cm.set_need("food", true)
	cm.set_need("power", true)
	assert_eq(cm.morale, 1.0, "morale is 1.0 when all 3 basic needs met")


func test_morale_0_6_when_one_basic_need_unmet() -> void:
	var cm = ColonyManager.new()
	cm.set_need("water", true)
	cm.set_need("food", true)
	# power unmet
	assert_eq(cm.morale, 0.6, "morale is 0.6 when 1 basic need unmet")


func test_morale_0_3_when_two_basic_needs_unmet() -> void:
	var cm = ColonyManager.new()
	cm.set_need("water", true)
	# food, power unmet
	assert_eq(cm.morale, 0.3, "morale is 0.3 when 2 basic needs unmet")


func test_luxury_goods_adds_morale_bonus() -> void:
	var cm = ColonyManager.new()
	cm.set_need("water", true)
	cm.set_need("food", true)
	cm.set_need("power", true)
	assert_eq(cm.morale, 1.0, "morale is 1.0 with all basic needs met, no luxury")

	cm.set_need("luxury_goods", true)
	assert_eq(cm.morale, 1.0, "morale caps at 1.0 even with luxury bonus")


func test_morale_changed_signal_fires() -> void:
	var cm = ColonyManager.new()
	var signal_received = false
	var new_morale = -1.0

	cm.morale_changed.connect(func(m: float) -> void:
		signal_received = true
		new_morale = m
	)

	cm.set_need("water", true)
	assert_true(signal_received, "morale_changed signal should fire")
	assert_eq(new_morale, 0.3, "signal should pass new morale value (0.3)")


# --- Housing Tests ---

func test_add_housing_basic_module() -> void:
	var cm = ColonyManager.new()
	assert_eq(cm.housing_capacity, 8, "starts with 8 (1 basic)")

	cm.add_housing("basic")
	assert_eq(cm.housing_capacity, 16, "adding basic module adds 8 capacity")


func test_add_housing_standard_module() -> void:
	var cm = ColonyManager.new()
	cm.add_housing("standard")
	assert_eq(cm.housing_capacity, 24, "8 (initial basic) + 16 (standard) = 24")


func test_add_housing_advanced_module() -> void:
	var cm = ColonyManager.new()
	cm.add_housing("advanced")
	assert_eq(cm.housing_capacity, 38, "8 (initial basic) + 30 (advanced) = 38")


# --- Serialization Tests ---

func test_roundtrip_serialization() -> void:
	var cm1 = ColonyManager.new()
	cm1.pioneer_count = 7
	cm1.housing_capacity = 24
	cm1.morale = 0.75
	cm1.set_need("water", true)
	cm1.set_need("food", true)

	var data = cm1.get_save_data()

	var cm2 = ColonyManager.new()
	cm2.load_save_data(data)

	assert_eq(cm2.pioneer_count, 7, "pioneer_count restored")
	assert_eq(cm2.housing_capacity, 24, "housing_capacity restored")
	assert_near(cm2.morale, 0.75, 0.001, "morale restored")
	assert_eq(cm2.needs_met["water"], true, "water need restored")
	assert_eq(cm2.needs_met["food"], true, "food need restored")
	assert_eq(cm2.needs_met["power"], false, "power need restored as unmet")
