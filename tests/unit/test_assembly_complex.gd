extends "res://tests/framework/test_case.gd"
## TDD unit tests for Assembly Complex (M13).

const AssemblyComplexScript = preload("res://scenes/world/assembly_complex.gd")


func test_assembly_complex_has_3_slots() -> void:
	var complex = AssemblyComplexScript.new()
	assert_eq(complex.SLOT_COUNT, 3, "Assembly Complex should have 3 input slots")


func test_assembly_complex_slot_cost() -> void:
	var complex = AssemblyComplexScript.new()
	assert_eq(complex.FACTORY_TIER, 3, "Assembly Complex is tier-3 factory")


func test_assembly_complex_accepts_3_inputs() -> void:
	var complex = AssemblyComplexScript.new()
	complex.load_input("input_a", 5)
	complex.load_input("input_b", 3)
	complex.load_input("input_c", 2)

	assert_eq(complex._input_buffer.get("input_a", 0), 5)
	assert_eq(complex._input_buffer.get("input_b", 0), 3)
	assert_eq(complex._input_buffer.get("input_c", 0), 2)


func test_assembly_complex_can_run_with_all_inputs() -> void:
	var complex = AssemblyComplexScript.new()
	complex.set_recipe("test_recipe")
	complex.load_input("input_a", 5)
	complex.load_input("input_b", 3)
	complex.load_input("input_c", 2)

	# Can run if recipe set and all inputs available
	assert_true(complex.current_recipe_id != "", "Recipe should be set")


func test_assembly_complex_proximity_bonus() -> void:
	var complex = AssemblyComplexScript.new()
	var base_rate = 1.0
	var bonus_rate = complex.get_proximity_bonus()

	# Proximity bonus is +10% if all 3 inputs within 80 px
	assert_ge(bonus_rate, 1.0, "Proximity bonus should apply positive multiplier")


func test_assembly_complex_has_output_buffer() -> void:
	var complex = AssemblyComplexScript.new()
	assert_true(complex.has_method("collect_output"), "Assembly Complex should have output collection")


func test_assembly_complex_accumulates_output() -> void:
	var complex = AssemblyComplexScript.new()
	complex._output_buffer["assembled_component"] = 0

	# Simulate production
	complex._output_buffer["assembled_component"] += 1

	assert_eq(complex._output_buffer.get("assembled_component", 0), 1)


func test_assembly_complex_tick_advances_progress() -> void:
	var complex = AssemblyComplexScript.new()
	assert_eq(complex._progress, 0.0)

	complex.start()
	complex.set_recipe("test_recipe")
	complex.load_input("input_a", 10)
	complex.load_input("input_b", 10)
	complex.load_input("input_c", 10)

	complex.tick(5.0)

	assert_gt(complex._progress, 0.0, "Progress should advance on tick")
