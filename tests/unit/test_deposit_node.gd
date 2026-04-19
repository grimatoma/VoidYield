extends "res://tests/framework/test_case.gd"
## TDD unit tests for DepositNode.
## Covers: initial state, survey stage advancement, quality generation,
##         slot limits by deposit size, and signal emission.


# --- Initial State Tests ---

func test_initial_survey_stage_zero() -> void:
	var deposit = DepositNode.new()
	assert_eq(deposit.survey_stage, 0, "initial survey_stage should be 0")


# --- Survey Stage Advancement Tests ---

func test_advance_survey_sets_stage() -> void:
	var deposit = DepositNode.new()
	deposit.advance_survey(1)
	assert_eq(deposit.survey_stage, 1, "survey_stage should be 1 after advance_survey(1)")
	deposit.advance_survey(2)
	assert_eq(deposit.survey_stage, 2, "survey_stage should be 2 after advance_survey(2)")
	deposit.advance_survey(4)
	assert_eq(deposit.survey_stage, 4, "survey_stage should be 4 after advance_survey(4)")


# --- Quality Tests ---

func test_quality_null_before_stage_2() -> void:
	var deposit = DepositNode.new()
	assert_null(deposit.quality, "quality should be null at stage 0")
	deposit.advance_survey(1)
	assert_null(deposit.quality, "quality should be null at stage 1")


func test_quality_generated_at_stage_2() -> void:
	var deposit = DepositNode.new()
	deposit.advance_survey(2)
	assert_not_null(deposit.quality, "quality should be generated at stage 2")


func test_quality_not_regenerated_at_stage_3() -> void:
	var deposit = DepositNode.new()
	deposit.concentration = 75.0
	deposit.advance_survey(2)
	var first_quality = deposit.quality
	var first_er = first_quality.attributes.get("ER", -1)

	deposit.advance_survey(3)
	var second_quality = deposit.quality
	var second_er = second_quality.attributes.get("ER", -1)

	# Same object (identity check via ER value being unchanged)
	assert_eq(first_er, second_er, "quality ER should not change when advancing from stage 2 to 3")
	assert_eq(first_quality, second_quality, "quality object should be the same instance")


# --- Slot Limit Tests ---

func test_slot_limit_small_is_1() -> void:
	var deposit = DepositNode.new()
	deposit.deposit_size = "small"
	assert_eq(deposit.get_slot_limit(), 1, "small deposit should have 1 harvester slot")


func test_slot_limit_medium_is_2() -> void:
	var deposit = DepositNode.new()
	deposit.deposit_size = "medium"
	assert_eq(deposit.get_slot_limit(), 2, "medium deposit should have 2 harvester slots")


func test_slot_limit_large_is_3() -> void:
	var deposit = DepositNode.new()
	deposit.deposit_size = "large"
	assert_eq(deposit.get_slot_limit(), 3, "large deposit should have 3 harvester slots")


func test_slot_limit_motherlode_is_3() -> void:
	var deposit = DepositNode.new()
	deposit.deposit_size = "motherlode"
	assert_eq(deposit.get_slot_limit(), 3, "motherlode deposit should have 3 harvester slots")


# --- Signal Tests ---

func test_survey_advanced_signal_emitted() -> void:
	var deposit = DepositNode.new()
	var signal_received = false
	var received_stage = -1

	deposit.survey_advanced.connect(func(stage: int) -> void:
		signal_received = true
		received_stage = stage
	)

	deposit.advance_survey(2)

	assert_true(signal_received, "survey_advanced signal should be emitted")
	assert_eq(received_stage, 2, "signal should pass the correct stage (2)")
