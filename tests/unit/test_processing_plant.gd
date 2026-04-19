extends "res://tests/framework/test_case.gd"
## Unit tests for ProcessingPlant factory tier 1.

const ProcessingPlantScript = preload("res://scenes/world/processing_plant.gd")

func test_initial_state_not_running() -> void:
	var plant = ProcessingPlantScript.new()
	assert_false(plant.is_running)


func test_set_recipe_valid_tier1() -> void:
	var plant = ProcessingPlantScript.new()
	var success = plant.set_recipe("smelt_vorax")
	assert_true(success)
	assert_eq(plant.current_recipe_id, "smelt_vorax")


func test_set_recipe_rejects_wrong_tier() -> void:
	var plant = ProcessingPlantScript.new()
	# Tier 1 plant cannot run tier 2 recipes
	var success = plant.set_recipe("craft_drill")
	assert_false(success)
	assert_eq(plant.current_recipe_id, "")


func test_set_recipe_rejects_unknown_recipe() -> void:
	var plant = ProcessingPlantScript.new()
	var success = plant.set_recipe("no_such_recipe")
	assert_false(success)
	assert_eq(plant.current_recipe_id, "")


func test_load_input_adds_to_buffer() -> void:
	var plant = ProcessingPlantScript.new()
	var loaded = plant.load_input("common", 5)
	assert_eq(loaded, 5)
	assert_has(plant._input_buffer, "common")
	assert_eq(plant._input_buffer["common"], 5)


func test_load_input_accumulates() -> void:
	var plant = ProcessingPlantScript.new()
	plant.load_input("common", 3)
	plant.load_input("common", 2)
	assert_eq(plant._input_buffer["common"], 5)


func test_can_run_when_inputs_available() -> void:
	var plant = ProcessingPlantScript.new()
	plant.set_recipe("smelt_vorax")
	plant.load_input("common", 5)
	assert_true(plant.can_run())


func test_cannot_run_when_recipe_not_set() -> void:
	var plant = ProcessingPlantScript.new()
	plant.load_input("common", 5)
	assert_false(plant.can_run())


func test_cannot_run_when_inputs_missing() -> void:
	var plant = ProcessingPlantScript.new()
	plant.set_recipe("smelt_vorax")
	plant.load_input("common", 2)  # Need 5
	assert_false(plant.can_run())


func test_cannot_run_when_output_buffer_full() -> void:
	var plant = ProcessingPlantScript.new()
	plant.set_recipe("smelt_vorax")
	plant.load_input("common", 5)
	# Fill output buffer to capacity
	for i in range(20):
		plant._output_buffer["steel_bar"] = plant._output_buffer.get("steel_bar", 0) + 1
	assert_false(plant.can_run(), "Output buffer at 20/20 should prevent run")


func test_tick_advances_progress() -> void:
	var plant = ProcessingPlantScript.new()
	plant.set_recipe("smelt_vorax")
	plant.load_input("common", 5)
	plant.start()

	assert_eq(plant._progress, 0.0)
	plant.tick(2.0)
	assert_near(plant._progress, 2.0, 0.001)


func test_tick_does_nothing_when_not_running() -> void:
	var plant = ProcessingPlantScript.new()
	plant.set_recipe("smelt_vorax")
	plant.load_input("common", 5)
	# Don't call start()

	plant.tick(5.0)
	assert_eq(plant._progress, 0.0)


func test_tick_does_nothing_when_cannot_run() -> void:
	var plant = ProcessingPlantScript.new()
	plant.set_recipe("smelt_vorax")
	plant.load_input("common", 2)  # Not enough
	plant.start()

	plant.tick(2.0)
	assert_eq(plant._progress, 0.0)


func test_tick_completes_cycle_at_recipe_time() -> void:
	var plant = ProcessingPlantScript.new()
	plant.set_recipe("smelt_vorax")  # 8.0 second recipe
	plant.load_input("common", 5)
	plant.start()

	plant.tick(8.0)

	assert_has(plant._output_buffer, "steel_bar")
	assert_eq(plant._output_buffer["steel_bar"], 1)


func test_cycle_consumes_inputs() -> void:
	var plant = ProcessingPlantScript.new()
	plant.set_recipe("smelt_vorax")
	plant.load_input("common", 5)
	assert_eq(plant._input_buffer["common"], 5)

	plant.start()
	plant.tick(8.0)

	assert_eq(plant._input_buffer.get("common", 0), 0)


func test_cycle_resets_progress() -> void:
	var plant = ProcessingPlantScript.new()
	plant.set_recipe("smelt_vorax")
	plant.load_input("common", 5)
	plant.start()

	plant.tick(8.0)
	assert_eq(plant._progress, 0.0)


var _signal_emitted = false
var _signal_recipe_id = ""
var _signal_outputs = {}

func test_cycle_emits_signal() -> void:
	var plant = ProcessingPlantScript.new()
	_signal_emitted = false
	_signal_recipe_id = ""
	_signal_outputs = {}

	plant.cycle_completed.connect(_on_cycle_completed)

	plant.set_recipe("smelt_vorax")
	plant.load_input("common", 5)
	plant.start()
	plant.tick(8.0)

	assert_true(_signal_emitted, "Signal should have been received")
	assert_eq(_signal_recipe_id, "smelt_vorax", "Recipe ID should match")
	assert_eq(_signal_outputs.get("steel_bar", 0), 1, "Output should have 1 steel_bar")


func _on_cycle_completed(recipe_id: String, outputs: Dictionary) -> void:
	_signal_emitted = true
	_signal_recipe_id = recipe_id
	_signal_outputs = outputs


func test_collect_output_removes_from_buffer() -> void:
	var plant = ProcessingPlantScript.new()
	plant.set_recipe("smelt_vorax")
	plant.load_input("common", 5)
	plant.start()
	plant.tick(8.0)

	var collected = plant.collect_output("steel_bar", 1)
	assert_eq(collected, 1)
	assert_eq(plant._output_buffer.get("steel_bar", 0), 0)


func test_collect_output_respects_available_amount() -> void:
	var plant = ProcessingPlantScript.new()
	plant.set_recipe("smelt_vorax")
	plant.load_input("common", 5)
	plant.start()
	plant.tick(8.0)

	var collected = plant.collect_output("steel_bar", 5)
	assert_eq(collected, 1, "Only 1 available, should return 1")
	assert_eq(plant._output_buffer.get("steel_bar", 0), 0)


func test_output_buffer_capped_at_20() -> void:
	var plant = ProcessingPlantScript.new()
	plant.set_recipe("smelt_vorax")

	# Try to manually add 25 to output
	plant._output_buffer["steel_bar"] = 25

	plant.load_input("common", 5)
	plant.start()
	plant.tick(8.0)

	# Should not complete cycle when already at 20+
	assert_eq(plant._output_buffer.get("steel_bar", 0), 25, "Output should not increase beyond cap")


func test_start_stop_toggle_running() -> void:
	var plant = ProcessingPlantScript.new()
	assert_false(plant.is_running)

	plant.start()
	assert_true(plant.is_running)

	plant.stop()
	assert_false(plant.is_running)


func test_multiple_cycles_in_sequence() -> void:
	var plant = ProcessingPlantScript.new()
	plant.set_recipe("smelt_vorax")
	plant.start()

	# First cycle
	plant.load_input("common", 5)
	plant.tick(8.0)
	assert_eq(plant._output_buffer["steel_bar"], 1)

	# Second cycle
	plant.load_input("common", 5)
	plant.tick(8.0)
	assert_eq(plant._output_buffer["steel_bar"], 2)


func test_default_quality_gives_1x_speed() -> void:
	var plant = ProcessingPlantScript.new()
	# No quality set (null) should give 1.0x speed modifier
	assert_eq(plant.effective_speed, 1.0, "Default quality should give 1.0x speed")


func test_high_pe_quality_increases_speed() -> void:
	var plant = ProcessingPlantScript.new()
	var lot = preload("res://data/ore_quality_lot.gd").new()
	lot.pe = 1000.0  # High PE

	plant.set_ore_quality(lot)
	var modifier = plant.effective_speed
	assert_gt(modifier, 1.0, "High PE should increase speed > 1.0x")


func test_high_ut_quality_increases_yield() -> void:
	var plant = ProcessingPlantScript.new()
	var lot = preload("res://data/ore_quality_lot.gd").new()
	lot.ut = 1000.0  # High UT

	plant.set_ore_quality(lot)
	plant.set_recipe("smelt_vorax")
	plant.load_input("common", 5)
	plant.start()
	plant.tick(8.0)

	# With high UT yield modifier, should get more output
	var output = plant._output_buffer.get("steel_bar", 0)
	assert_gt(output, 1, "High UT should increase yield > 1")


func test_set_ore_quality_updates_modifiers() -> void:
	var plant = ProcessingPlantScript.new()
	var lot1 = preload("res://data/ore_quality_lot.gd").new()
	lot1.pe = 500.0  # Neutral PE

	plant.set_ore_quality(lot1)
	var speed1 = plant.effective_speed

	var lot2 = preload("res://data/ore_quality_lot.gd").new()
	lot2.pe = 1000.0  # High PE

	plant.set_ore_quality(lot2)
	var speed2 = plant.effective_speed

	assert_gt(speed2, speed1, "Speed should increase when quality improves")
