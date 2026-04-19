extends "res://tests/framework/test_case.gd"
## TDD unit tests for GameState ↔ TechTree integration
## Covers: save/load of unlocked nodes, research points

var save_data: Dictionary


func before_each() -> void:
	# Reset TechTree to clean state
	TechTree.reset()
	save_data = {}


func after_each() -> void:
	save_data.clear()
	TechTree.reset()


func test_save_includes_tech_tree_data() -> void:
	TechTree.unlocked_nodes.append("fabricator_tier_1")
	TechTree.research_points = 50.0

	save_data = GameState.get_save_data()
	assert_true(save_data.has("tech_tree"), "Save should include tech_tree key")
	assert_true(save_data["tech_tree"].has("unlocked"), "tech_tree should have unlocked")
	assert_true(save_data["tech_tree"].has("rp"), "tech_tree should have rp")


func test_save_includes_research_points() -> void:
	TechTree.research_points = 75.0

	save_data = GameState.get_save_data()
	assert_eq(save_data["tech_tree"]["rp"], 75.0, "Should save research points")


func test_load_restores_tech_tree_unlocked_nodes() -> void:
	TechTree.unlocked_nodes.append("fabricator_tier_1")
	TechTree.unlocked_nodes.append("drone_swarm")
	TechTree.research_points = 100.0

	# Get save data and reset
	save_data = GameState.get_save_data()
	TechTree.reset()

	# Verify TechTree is clean
	assert_false(TechTree.is_unlocked("fabricator_tier_1"), "Should be reset")
	assert_eq(TechTree.rp, 0.0, "RP should be reset")

	# Load from save
	GameState.load_save_data(save_data)

	# Verify restored
	assert_true(TechTree.is_unlocked("fabricator_tier_1"), "Should restore fabricator_tier_1")
	assert_true(TechTree.is_unlocked("drone_swarm"), "Should restore drone_swarm")
	assert_eq(TechTree.rp, 100.0, "Should restore research points")
