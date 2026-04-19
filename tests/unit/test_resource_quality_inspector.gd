extends "res://tests/framework/test_case.gd"
## TDD unit tests for ResourceQualityInspector.

const ResourceQualityInspectorScript = preload("res://scenes/ui/resource_quality_inspector.gd")
const OreQualityLotScript = preload("res://data/ore_quality_lot.gd")

var inspector


func before_each() -> void:
	inspector = ResourceQualityInspectorScript.new()
	add_child(inspector)


func after_each() -> void:
	if inspector and inspector.is_inside_tree():
		inspector.queue_free()


func test_initial_no_lot() -> void:
	assert_null(inspector.current_lot, "Should start with no lot")


func test_inspect_sets_lot() -> void:
	var lot = OreQualityLotScript.new()
	lot.er = 800.0

	inspector.inspect(lot)

	assert_eq(inspector.current_lot, lot, "Should set current_lot")


func test_get_grade_no_lot_returns_dash() -> void:
	assert_eq(inspector.get_grade(), "—", "Should return dash when no lot")


func test_get_grade_with_lot() -> void:
	var lot = OreQualityLotScript.new()
	lot.er = 800.0

	inspector.inspect(lot)

	assert_eq(inspector.get_grade(), "A", "Grade A when ER >= 800")


func test_get_attribute_no_lot_returns_zero() -> void:
	assert_eq(inspector.get_attribute("er"), 0.0, "Should return 0 when no lot")


func test_get_attribute_with_lot() -> void:
	var lot = OreQualityLotScript.new()
	lot.er = 750.0

	inspector.inspect(lot)

	assert_eq(inspector.get_attribute("er"), 750.0, "Should return attribute value")


func test_get_summary_empty_when_no_lot() -> void:
	var summary = inspector.get_summary()
	assert_true(summary.is_empty(), "Should return empty dict when no lot")


func test_get_summary_with_lot_has_all_fields() -> void:
	var lot = OreQualityLotScript.new()
	lot.er = 750.0
	lot.cr = 650.0
	lot.cd = 550.0
	lot.dr = 450.0
	lot.fl = 350.0
	lot.hr = 250.0
	lot.ma = 150.0
	lot.pe = 100.0
	lot.sr = 200.0
	lot.ut = 300.0

	inspector.inspect(lot)
	var summary = inspector.get_summary()

	assert_has(summary, "grade")
	assert_has(summary, "er")
	assert_has(summary, "cr")
	assert_has(summary, "cd")
	assert_has(summary, "dr")
	assert_has(summary, "fl")
	assert_has(summary, "hr")
	assert_has(summary, "ma")
	assert_has(summary, "pe")
	assert_has(summary, "sr")
	assert_has(summary, "ut")


func test_lot_updated_signal_fires() -> void:
	var signal_received = []
	inspector.lot_updated.connect(func(lot):
		signal_received.append(lot)
	)

	var lot = OreQualityLotScript.new()
	inspector.inspect(lot)

	assert_eq(signal_received.size(), 1, "Signal should fire")
	assert_eq(signal_received[0], lot, "Signal should pass lot")


func test_clear_removes_lot() -> void:
	var lot = OreQualityLotScript.new()
	inspector.inspect(lot)

	assert_not_null(inspector.current_lot)

	inspector.clear()

	assert_null(inspector.current_lot, "Should clear current_lot")
