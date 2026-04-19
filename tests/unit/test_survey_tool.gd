extends "res://tests/framework/test_case.gd"
## TDD unit tests for Survey Tool tier system.
## Covers: tier progression, range/precision bonuses, scan stages.

func before_each() -> void:
	reset_game_state()
	TechTree.research_points = 0.0
	TechTree.unlocked_nodes.clear()


func after_each() -> void:
	TechTree.research_points = 0.0
	TechTree.unlocked_nodes.clear()


# --- Tier Access ---

func test_default_tier_is_one() -> void:
	var tier = GameState.get_survey_tool_tier()
	assert_eq(tier, 1, "Survey Tool should start at Tier I")


func test_tier_one_has_30px_range() -> void:
	var range_px = GameState.get_survey_range(1)
	assert_eq(range_px, 30, "Tier I has 30px range")


func test_tier_two_has_60px_range() -> void:
	var range_px = GameState.get_survey_range(2)
	assert_eq(range_px, 60, "Tier II has 60px range")


func test_tier_three_has_120px_range() -> void:
	var range_px = GameState.get_survey_range(3)
	assert_eq(range_px, 120, "Tier III has 120px range")


# --- Precision ---

func test_tier_one_has_15_percent_precision() -> void:
	var precision = GameState.get_survey_precision(1)
	assert_eq(precision, 0.15, "Tier I has ±15% precision")


func test_tier_two_has_5_percent_precision() -> void:
	var precision = GameState.get_survey_precision(2)
	assert_eq(precision, 0.05, "Tier II has ±5% precision")


func test_tier_three_has_1_percent_precision() -> void:
	var precision = GameState.get_survey_precision(3)
	assert_eq(precision, 0.01, "Tier III has ±1% precision")


# --- Tier Advancement via Tech Tree ---

func test_unlock_survey_tool_mk_ii_advances_tier() -> void:
	GameState.credits = 1000
	TechTree.add_rp(500.0)

	# Unlock node 3.S (Survey Tool Mk.II)
	assert_true(TechTree.can_unlock("3.S"), "Should have resources to unlock 3.S")
	TechTree.unlock("3.S")

	var tier = GameState.get_survey_tool_tier()
	assert_eq(tier, 2, "Should advance to Tier II after unlocking 3.S")


func test_unlock_survey_tool_mk_iii_advances_tier() -> void:
	GameState.credits = 5000
	TechTree.add_rp(3000.0)

	# Unlock 3.S first
	TechTree.unlock("3.S")
	var tier = GameState.get_survey_tool_tier()
	assert_eq(tier, 2, "Should be at Tier II after unlocking 3.S")

	# Then unlock 3.T (requires 3.S)
	assert_true(TechTree.can_unlock("3.T"), "Should be able to unlock 3.T after 3.S")
	TechTree.unlock("3.T")

	tier = GameState.get_survey_tool_tier()
	assert_eq(tier, 3, "Should advance to Tier III after unlocking 3.T")


# --- Scan Stages (based on spec 02) ---

func test_tier_ii_enables_deep_scan() -> void:
	GameState.credits = 1000
	TechTree.add_rp(500.0)
	TechTree.unlock("3.S")

	# Tier II enables deep scan (returns 3 top attributes)
	var can_deep_scan = GameState.can_deep_scan()
	assert_true(can_deep_scan, "Tier II should enable deep scan")


func test_tier_i_cannot_deep_scan() -> void:
	# No tech unlock = Tier I
	var can_deep_scan = GameState.can_deep_scan()
	assert_false(can_deep_scan, "Tier I cannot perform deep scan")


func test_tier_iii_shows_full_attributes() -> void:
	GameState.credits = 5000
	TechTree.add_rp(3000.0)
	TechTree.unlock("3.S")
	TechTree.unlock("3.T")

	var shows_all = GameState.survey_shows_all_attributes()
	assert_true(shows_all, "Tier III shows all 11 attributes")


# --- Persistence ---

func test_survey_tier_saved_and_restored() -> void:
	GameState.credits = 1000
	TechTree.add_rp(500.0)
	TechTree.unlock("3.S")

	# At Tier II
	var tier_before = GameState.get_survey_tool_tier()
	assert_eq(tier_before, 2)

	# Save and load game state
	var save_data = GameState.get_save_data()
	GameState.credits = 0
	TechTree.unlocked_nodes.clear()

	# Restore
	GameState.load_save_data(save_data)

	var tier_after = GameState.get_survey_tool_tier()
	assert_eq(tier_after, 2, "Should restore survey tool tier")
