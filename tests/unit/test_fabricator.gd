extends "res://tests/framework/test_case.gd"

const FabricatorScript = preload("res://scenes/world/fabricator.gd")

var fabricator


func before_each() -> void:
	fabricator = FabricatorScript.new()
	add_child(fabricator)


func after_each() -> void:
	if fabricator and fabricator.is_inside_tree():
		fabricator.queue_free()


func test_initial_not_running() -> void:
	assert_false(fabricator.is_running, "Should start not running")


func test_set_recipe_sets_id() -> void:
	fabricator.set_recipe("craft_drill")
	assert_eq(fabricator.current_recipe_id, "craft_drill", "Should set recipe ID")


func test_load_input_within_limit() -> void:
	var loaded = fabricator.load_input("steel_bar", 10)
	assert_eq(loaded, 10, "Should load within limit")
	assert_eq(fabricator._input_buffers.get("steel_bar", 0), 10, "Should store loaded input")


func test_load_input_capped_at_20() -> void:
	var loaded = fabricator.load_input("steel_bar", 50)
	assert_eq(loaded, 20, "Should cap at 20 per type")
	assert_eq(fabricator._input_buffers.get("steel_bar", 0), 20, "Should store capped amount")


func test_load_input_returns_actual_loaded() -> void:
	fabricator.load_input("steel_bar", 15)
	var second = fabricator.load_input("steel_bar", 20)
	assert_eq(second, 5, "Should return space remaining (20-15=5)")
	assert_eq(fabricator._input_buffers.get("steel_bar", 0), 20, "Should be capped at 20")


func test_can_run_false_no_recipe() -> void:
	assert_false(fabricator.can_run(), "Should not run without recipe")


func test_can_run_false_no_inputs() -> void:
	fabricator.set_recipe("craft_drill")
	assert_false(fabricator.can_run(), "Should not run without inputs")


func test_can_run_true_with_inputs() -> void:
	fabricator.set_recipe("craft_drill")
	fabricator.load_input("steel_bar", 4)
	fabricator.load_input("common", 2)
	assert_true(fabricator.can_run(), "Should run with all inputs")


func test_tick_advances_progress() -> void:
	fabricator.set_recipe("craft_drill")
	fabricator.load_input("steel_bar", 4)
	fabricator.load_input("common", 2)
	fabricator.start()
	fabricator.tick(5.0)
	assert_gt(fabricator._progress, 0.0, "Should advance progress")


func test_tick_completes_cycle_after_duration() -> void:
	fabricator.set_recipe("craft_drill")
	fabricator.load_input("steel_bar", 4)
	fabricator.load_input("common", 2)
	fabricator.start()
	fabricator.tick(20.0)  # craft_drill takes 20s
	assert_eq(fabricator._progress, 0.0, "Should reset progress after cycle")
	assert_gt(fabricator._output_buffer.get("basic_drill", 0), 0, "Should have output")


func test_output_buffer_capped_at_10() -> void:
	fabricator.set_recipe("craft_drill")
	# Load inputs multiple times to bypass 20 cap per load
	fabricator.load_input("steel_bar", 20)
	fabricator._input_buffers["steel_bar"] = 50  # Manually set to test cap
	fabricator.load_input("common", 20)
	fabricator._input_buffers["common"] = 50  # Manually set to test cap
	fabricator.start()
	for i in 12:
		fabricator.tick(20.0)
	assert_eq(fabricator._output_buffer.get("basic_drill", 0), 10, "Output should cap at 10")


func test_collect_output_removes_from_buffer() -> void:
	fabricator.set_recipe("craft_drill")
	fabricator.load_input("steel_bar", 4)
	fabricator.load_input("common", 2)
	fabricator.start()
	fabricator.tick(20.0)
	var output_amount = fabricator._output_buffer.get("basic_drill", 0)
	var collected = fabricator.collect_output("basic_drill", 1)
	assert_eq(collected, 1, "Should collect output")
	assert_eq(fabricator._output_buffer.get("basic_drill", 0), output_amount - 1, "Should reduce buffer")


func test_start_sets_running() -> void:
	fabricator.start()
	assert_true(fabricator.is_running, "Should be running after start()")


func test_stop_clears_running() -> void:
	fabricator.start()
	fabricator.stop()
	assert_false(fabricator.is_running, "Should stop running after stop()")


func test_cycle_completed_signal_fires() -> void:
	fabricator.set_recipe("craft_drill")
	fabricator.load_input("steel_bar", 4)
	fabricator.load_input("common", 2)
	fabricator.start()

	var signal_received = []
	fabricator.cycle_completed.connect(func(rid):
		signal_received.append(rid)
	)

	fabricator.tick(20.0)

	assert_gt(signal_received.size(), 0, "Signal should fire on cycle complete")
	assert_eq(signal_received[0], "craft_drill", "Signal should pass recipe ID")


func test_set_recipe_accepts_tier2_recipe() -> void:
	fabricator.set_recipe("craft_drill")
	assert_eq(fabricator.current_recipe_id, "craft_drill", "Should accept tier-2 recipe")


func test_set_recipe_rejects_tier1_recipe() -> void:
	fabricator.set_recipe("smelt_vorax")
	assert_eq(fabricator.current_recipe_id, "", "Should reject tier-1 recipe (smelt_vorax)")


func test_set_recipe_rejects_tier3_recipe() -> void:
	fabricator.set_recipe("craft_harvester")
	assert_eq(fabricator.current_recipe_id, "", "Should reject tier-3 recipe (craft_harvester)")


func test_set_recipe_accepts_craft_surveyor() -> void:
	fabricator.set_recipe("craft_surveyor")
	assert_eq(fabricator.current_recipe_id, "craft_surveyor", "Should accept craft_surveyor (tier-2)")


func test_set_recipe_accepts_craft_fuel_cell() -> void:
	fabricator.set_recipe("craft_fuel_cell")
	assert_eq(fabricator.current_recipe_id, "craft_fuel_cell", "Should accept craft_fuel_cell (tier-2)")


func test_set_recipe_accepts_craft_drone_frame() -> void:
	fabricator.set_recipe("craft_drone_frame")
	assert_eq(fabricator.current_recipe_id, "craft_drone_frame", "Should accept craft_drone_frame (tier-2)")
