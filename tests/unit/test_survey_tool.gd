extends "res://tests/framework/test_case.gd"

const SurveyToolScript = preload("res://scenes/world/survey_tool.gd")

## Mock DepositNode for testing
class MockDeposit:
	var survey_stage: int = 0
	var survey_signal_received = false

	func advance_survey(stage: int) -> void:
		survey_stage = stage
		survey_signal_received = true


var tool


func before_each() -> void:
	tool = SurveyToolScript.new()
	add_child(tool)


func after_each() -> void:
	if tool and tool.is_inside_tree():
		tool.queue_free()


func test_initial_not_scanning() -> void:
	assert_false(tool.is_scanning, "Should not be scanning initially")


func test_scan_deposit_advances_survey() -> void:
	var deposit = MockDeposit.new()
	tool.scan_deposits([deposit], 1)
	assert_eq(deposit.survey_stage, 1, "Should advance deposit survey")


func test_scan_multiple_deposits() -> void:
	var dep1 = MockDeposit.new()
	var dep2 = MockDeposit.new()
	tool.scan_deposits([dep1, dep2], 2)
	assert_eq(dep1.survey_stage, 2, "Should survey first deposit")
	assert_eq(dep2.survey_stage, 2, "Should survey second deposit")


func test_scan_sets_is_scanning() -> void:
	var deposit = MockDeposit.new()
	tool.scan_deposits([deposit], 1)
	assert_true(tool.is_scanning, "Should set is_scanning to true")


func test_scan_complete_signal() -> void:
	var signal_received = []
	tool.scan_completed.connect(func(count):
		signal_received.append(count)
	)
	var deposits = [MockDeposit.new(), MockDeposit.new()]
	tool.scan_deposits(deposits, 1)
	assert_gt(signal_received.size(), 0, "Should emit scan_completed signal")
	assert_eq(signal_received[0], 2, "Should pass deposit count scanned")


func test_scan_clears_is_scanning() -> void:
	var deposit = MockDeposit.new()
	tool.scan_deposits([deposit], 1)
	tool.complete_scan()
	assert_false(tool.is_scanning, "Should clear is_scanning after completion")
