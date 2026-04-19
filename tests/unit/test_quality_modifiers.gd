extends "res://tests/framework/test_case.gd"
## TDD unit tests for QualityModifiers system.

const QualityModifiersScript = preload("res://data/quality_modifiers.gd")
const OreQualityLotScript = preload("res://data/ore_quality_lot.gd")


func test_speed_modifier_null_lot_returns_one() -> void:
	var mod = QualityModifiersScript.get_speed_modifier(null)
	assert_eq(mod, 1.0, "Should return 1.0 for null lot")


func test_speed_modifier_high_pe_gives_high_multiplier() -> void:
	var lot = OreQualityLotScript.new()
	lot.pe = 1000.0  # Max PE

	var mod = QualityModifiersScript.get_speed_modifier(lot)
	assert_gt(mod, 1.0, "High PE should give multiplier > 1.0")


func test_speed_modifier_clamped_to_range() -> void:
	var lot = OreQualityLotScript.new()
	lot.pe = 100.0  # Very low

	var mod = QualityModifiersScript.get_speed_modifier(lot)
	assert_ge(mod, 0.5, "Should clamp to minimum 0.5")
	assert_le(mod, 2.0, "Should clamp to maximum 2.0")


func test_yield_modifier_null_lot_returns_one() -> void:
	var mod = QualityModifiersScript.get_yield_modifier(null)
	assert_eq(mod, 1.0, "Should return 1.0 for null lot")


func test_yield_modifier_high_ut_gives_high_multiplier() -> void:
	var lot = OreQualityLotScript.new()
	lot.ut = 1000.0  # Max UT

	var mod = QualityModifiersScript.get_yield_modifier(lot)
	assert_gt(mod, 1.0, "High UT should give multiplier > 1.0")


func test_yield_modifier_clamped_to_range() -> void:
	var lot = OreQualityLotScript.new()
	lot.ut = 100.0  # Very low

	var mod = QualityModifiersScript.get_yield_modifier(lot)
	assert_ge(mod, 0.5, "Should clamp to minimum 0.5")
	assert_le(mod, 1.5, "Should clamp to maximum 1.5")


func test_quality_tier_null_returns_standard() -> void:
	var tier = QualityModifiersScript.get_quality_tier(null)
	assert_eq(tier, "standard", "Should return standard for null lot")


func test_quality_tier_a_grade_returns_premium() -> void:
	var lot = OreQualityLotScript.new()
	lot.er = 800.0  # Grade A

	var tier = QualityModifiersScript.get_quality_tier(lot)
	assert_eq(tier, "premium", "Grade A should be premium")


func test_quality_tier_f_grade_returns_low() -> void:
	var lot = OreQualityLotScript.new()
	lot.er = 100.0  # Grade F

	var tier = QualityModifiersScript.get_quality_tier(lot)
	assert_eq(tier, "low", "Grade F should be low")
