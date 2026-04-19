extends "res://tests/framework/test_case.gd"
## Unit tests for Survey Tool tier upgrades.

const SurveyToolScript = preload("res://autoloads/survey_tool_system.gd")


func test_survey_tool_starts_at_tier_1() -> void:
	var tool = SurveyToolScript.new()
	assert_eq(tool.upgrade_level, 1, "Should start at tier 1")


func test_survey_tool_tier_1_radius() -> void:
	var tool = SurveyToolScript.new()
	tool.upgrade_level = 1
	assert_eq(tool.get_scan_radius(), 30.0, "Tier 1 should have 30px radius")


func test_survey_tool_tier_2_radius() -> void:
	var tool = SurveyToolScript.new()
	tool.upgrade_level = 2
	assert_eq(tool.get_scan_radius(), 60.0, "Tier 2 should have 60px radius")


func test_survey_tool_tier_3_radius() -> void:
	var tool = SurveyToolScript.new()
	tool.upgrade_level = 3
	assert_eq(tool.get_scan_radius(), 120.0, "Tier 3 should have 120px radius")


func test_survey_tool_tier_2_has_deep_scan() -> void:
	var tool = SurveyToolScript.new()
	tool.upgrade_level = 2
	assert_true(tool.can_deep_scan(), "Tier 2 should enable deep scan")


func test_survey_tool_tier_1_no_deep_scan() -> void:
	var tool = SurveyToolScript.new()
	tool.upgrade_level = 1
	assert_false(tool.can_deep_scan(), "Tier 1 should not have deep scan")
